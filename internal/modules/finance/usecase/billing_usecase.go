package usecase

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/hex"
	"errors"
	"fmt"
	"math/rand"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"
	coreDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/domain"
)

const (
	cashAdminFee = 5000.0 // Biaya admin pembayaran tunai via Midtrans (menguap ke gateway)
)

type billingUsecase struct {
	repo          domain.BillingRepository
	ledgerUsecase domain.LedgerUsecase
	coreRepo      coreDomain.CoreRepository
	hmacSecret    string
	midtransKey   string
}

func NewBillingUsecase(
	repo domain.BillingRepository,
	ledgerUc domain.LedgerUsecase,
	coreRepo coreDomain.CoreRepository,
	hmacSecret string,
	midtransServerKey string,
) domain.BillingUsecase {
	return &billingUsecase{
		repo:          repo,
		ledgerUsecase: ledgerUc,
		coreRepo:      coreRepo,
		hmacSecret:    hmacSecret,
		midtransKey:   midtransServerKey,
	}
}

// generateQRCode membuat kode QR dinamis unik 16 karakter
func generateQRCode() string {
	const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	b := make([]byte, 16)
	for i := range b {
		b[i] = chars[r.Intn(len(chars))]
	}
	return string(b)
}

// generateRFIDCode membuat kode RFID unik 12 digit angka murni
// Hanya angka karena diketik manual di terminal IoT RFID fisik
func generateRFIDCode() string {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	return fmt.Sprintf("%012d", r.Int63n(1_000_000_000_000))
}

// generateVA membuat Virtual Account 15 digit: 12 account_number + 3 digit unik
func generateVA(baseAccountNumber string, uniqueSuffix int) string {
	suffix := fmt.Sprintf("%03d", uniqueSuffix%1000)
	if len(baseAccountNumber) >= 12 {
		return baseAccountNumber[:12] + suffix
	}
	return baseAccountNumber + suffix
}

func (u *billingUsecase) hashPIN(pin string) string {
	h := hmac.New(sha256.New, []byte(u.hmacSecret))
	h.Write([]byte(pin))
	return hex.EncodeToString(h.Sum(nil))
}

func (u *billingUsecase) verifyPIN(ctx context.Context, userID uuid.UUID, pin string) error {
	user, err := u.coreRepo.GetUserByID(ctx, userID)
	if err != nil {
		return err
	}
	if user == nil {
		return errors.New("pengguna tidak ditemukan")
	}
	if user.PinHash == "" {
		return errors.New("PIN belum disetel untuk pengguna ini")
	}
	if user.PinHash != u.hashPIN(pin) {
		return errors.New("PIN tidak valid")
	}
	return nil
}

// resolveInvoiceStatus menentukan status tagihan berdasarkan jumlah yang sudah dibayar
func resolveInvoiceStatus(inv *domain.StudentInvoice, newPaidTotal float64) string {
	if newPaidTotal >= inv.TotalAmount {
		return "PAID"
	}
	return "PARTIAL"
}

// applyPayment adalah fungsi inti untuk menerapkan pembayaran cicilan/penuh pada tagihan
func (u *billingUsecase) applyPayment(ctx context.Context, inv *domain.StudentInvoice, payerID uuid.UUID, amount float64, refDesc string) error {
	if inv.Status == "PAID" {
		return errors.New("tagihan sudah lunas")
	}
	if inv.Status == "EXPIRED" {
		return errors.New("tagihan sudah kedaluwarsa / tidak valid")
	}
	// Validasi expiry via DueDate
	if inv.DueDate != nil && time.Now().After(*inv.DueDate) {
		// Auto-invalidate
		_ = u.repo.UpdateInvoiceStatus(ctx, inv.ID, inv.PaidAmount, "EXPIRED")
		return errors.New("tagihan sudah kedaluwarsa")
	}

	remaining := inv.TotalAmount - inv.PaidAmount
	if amount <= 0 {
		return errors.New("jumlah pembayaran harus lebih dari 0")
	}
	if amount > remaining {
		return fmt.Errorf("jumlah melebihi sisa tagihan (Rp %.0f)", remaining)
	}

	// Validasi cicilan
	if amount < remaining {
		if !inv.CanInstallment {
			return errors.New("tagihan ini tidak bisa dicicil, harus dibayar penuh")
		}
		if inv.MinimumInstallment > 0 && amount < inv.MinimumInstallment {
			return fmt.Errorf("minimal cicilan adalah Rp %.0f", inv.MinimumInstallment)
		}
	}

	// Catat di ledger
	refType := "INVOICE_PAYMENT"
	invID := inv.ID
	ledgerReq := &domain.WalletLedger{
		ID:              uuid.New(),
		TenantID:        inv.TenantID,
		UserID:          payerID,
		TransactionType: domain.TxDebit,
		Amount:          amount,
		Fee:             0,
		ReferenceType:   &refType,
		ReferenceID:     &invID,
		Description:     refDesc,
	}

	ledgerRes, err := u.ledgerUsecase.RecordTransaction(ctx, ledgerReq)
	if err != nil {
		return err
	}

	newPaidTotal := inv.PaidAmount + amount
	newStatus := resolveInvoiceStatus(inv, newPaidTotal)

	if err := u.repo.UpdateInvoiceStatus(ctx, inv.ID, newPaidTotal, newStatus); err != nil {
		return err
	}

	return u.repo.RecordPayment(ctx, inv.ID, ledgerRes.ID, amount)
}

// GenerateMassInvoices membuat tagihan massal untuk semua siswa target
func (u *billingUsecase) GenerateMassInvoices(ctx context.Context, tenantID uuid.UUID, req domain.GenerateInvoiceRequest) error {
	studentIDs, err := u.repo.GetStudentsByTarget(ctx, tenantID, req.TargetClass, req.TargetMajor)
	if err != nil {
		return err
	}
	if len(studentIDs) == 0 {
		return errors.New("tidak ada siswa ditemukan untuk target yang diberikan")
	}

	// Ambil account_number sekolah/tenant untuk generate VA
	// Kita gunakan prefix sederhana dari tenant ID untuk VA
	tenantIDShort := strings.Replace(tenantID.String(), "-", "", -1)[:8]

	var invoices []*domain.StudentInvoice
	for i, studentID := range studentIDs {
		qrCode := generateQRCode()
		rfidCode := generateRFIDCode()
		va := generateVA(tenantIDShort, i)

		invoices = append(invoices, &domain.StudentInvoice{
			ID:                    uuid.New(),
			TenantID:              tenantID,
			StudentID:             studentID,
			FeeID:                 req.FeeTypeID,
			InvoiceName:           req.InvoiceName,
			TotalAmount:           req.Amount,
			PaidAmount:            0,
			Status:                "PENDING",
			CanInstallment:        req.CanInstallment,
			MinimumInstallment:    req.MinimumInstallment,
			DynamicQRCode:         &qrCode,
			RFIDPaymentCode:       &rfidCode,
			TransferTargetAccount: &va,
			DueDate:               req.DueDate,
		})
	}

	return u.repo.BatchInsertInvoices(ctx, invoices)
}

func (u *billingUsecase) GetStudentInvoices(ctx context.Context, tenantID, studentID uuid.UUID) ([]*domain.StudentInvoice, error) {
	return u.repo.GetStudentInvoices(ctx, tenantID, studentID)
}

// PayInvoiceDynamicQR — Pembayaran via scan QR Dinamis (oleh siswa/ortu dengan PIN)
func (u *billingUsecase) PayInvoiceDynamicQR(ctx context.Context, payerID uuid.UUID, qrCode string, amount float64, pin string) error {
	if err := u.verifyPIN(ctx, payerID, pin); err != nil {
		return err
	}

	inv, err := u.repo.GetInvoiceByDynamicQR(ctx, qrCode)
	if err != nil {
		return err
	}
	if inv == nil {
		return errors.New("kode QR tidak valid atau tagihan tidak ditemukan")
	}

	desc := fmt.Sprintf("Bayar Tagihan: %s", inv.InvoiceName)
	return u.applyPayment(ctx, inv, payerID, amount, desc)
}

// GetInvoiceForIoT — Mesin RFID IoT mengambil info tagihan sebelum pembayaran
func (u *billingUsecase) GetInvoiceForIoT(ctx context.Context, rfidCode string) (*domain.StudentInvoice, error) {
	inv, err := u.repo.GetInvoiceByRFIDCode(ctx, rfidCode)
	if err != nil {
		return nil, err
	}
	if inv == nil {
		return nil, errors.New("kode RFID tagihan tidak valid")
	}
	if inv.Status == "PAID" {
		return nil, errors.New("tagihan sudah lunas")
	}
	if inv.Status == "EXPIRED" {
		return nil, errors.New("tagihan sudah kedaluwarsa")
	}
	if inv.DueDate != nil && time.Now().After(*inv.DueDate) {
		_ = u.repo.UpdateInvoiceStatus(ctx, inv.ID, inv.PaidAmount, "EXPIRED")
		return nil, errors.New("tagihan sudah kedaluwarsa")
	}
	return inv, nil
}

// PayInvoiceRFID — Mesin RFID IoT memproses pembayaran setelah tap kartu
func (u *billingUsecase) PayInvoiceRFID(ctx context.Context, rfidCode, rfidTag, pin string, amount float64) error {
	// Identifikasi pembayar dari RFID tag
	buyer, err := u.coreRepo.GetUserByRFID(ctx, rfidTag)
	if err != nil {
		return err
	}
	if buyer == nil {
		return errors.New("kartu RFID tidak dikenali")
	}

	if err := u.verifyPIN(ctx, buyer.ID, pin); err != nil {
		return err
	}

	inv, err := u.GetInvoiceForIoT(ctx, rfidCode)
	if err != nil {
		return err
	}

	desc := fmt.Sprintf("Bayar Tagihan RFID: %s", inv.InvoiceName)
	return u.applyPayment(ctx, inv, buyer.ID, amount, desc)
}

// GetInvoiceByVA — Saat siswa input VA 15 digit, sistem otomatis menampilkan detail tagihan
// Endpoint ini tidak butuh PIN; hanya untuk preview tagihan sebelum konfirmasi bayar
func (u *billingUsecase) GetInvoiceByVA(ctx context.Context, va string) (*domain.StudentInvoice, error) {
	inv, err := u.repo.GetInvoiceByTransferAccount(ctx, va)
	if err != nil {
		return nil, err
	}
	if inv == nil {
		return nil, errors.New("kode VA tidak valid atau tagihan tidak ditemukan")
	}
	if inv.Status == "PAID" {
		return nil, errors.New("tagihan sudah lunas, kode VA ini sudah hangus")
	}
	if inv.Status == "EXPIRED" {
		return nil, errors.New("tagihan sudah kedaluwarsa")
	}
	if inv.DueDate != nil && time.Now().After(*inv.DueDate) {
		_ = u.repo.UpdateInvoiceStatus(ctx, inv.ID, inv.PaidAmount, "EXPIRED")
		return nil, errors.New("tagihan sudah kedaluwarsa")
	}
	return inv, nil
}

// PayInvoiceVA — Eksekusi bayar menggunakan VA 15 digit (wajib PIN, kemudian VA hangus)
func (u *billingUsecase) PayInvoiceVA(ctx context.Context, payerID uuid.UUID, va string, pin string) error {
	if err := u.verifyPIN(ctx, payerID, pin); err != nil {
		return err
	}

	inv, err := u.GetInvoiceByVA(ctx, va)
	if err != nil {
		return err
	}

	// Bayar penuh sisa tagihan
	remaining := inv.TotalAmount - inv.PaidAmount
	desc := fmt.Sprintf("Bayar Tagihan (VA): %s", inv.InvoiceName)
	if err := u.applyPayment(ctx, inv, payerID, remaining, desc); err != nil {
		return err
	}

	// Hanguskan VA setelah berhasil dibayar (set NULL agar tidak bisa dipakai lagi)
	// Ini dilakukan via UpdateInvoiceStatus yang sudah meng-update status menjadi PAID/PARTIAL
	// VA sudah tidak bisa diakses karena GetInvoiceByVA akan mengembalikan error jika status = PAID
	return nil
}

// InitiateCashPayment — Admin keuangan memulai pembayaran tunai melalui Midtrans Snap
func (u *billingUsecase) InitiateCashPayment(ctx context.Context, adminID, invoiceID uuid.UUID, amount float64) (*domain.CashPaymentResponse, error) {
	inv, err := u.repo.GetInvoiceByID(ctx, invoiceID)
	if err != nil {
		return nil, err
	}
	if inv == nil {
		return nil, errors.New("tagihan tidak ditemukan")
	}
	if inv.Status == "PAID" {
		return nil, errors.New("tagihan sudah lunas")
	}
	if inv.Status == "EXPIRED" {
		return nil, errors.New("tagihan sudah kedaluwarsa")
	}

	remaining := inv.TotalAmount - inv.PaidAmount
	if amount <= 0 {
		amount = remaining // Default ke sisa tagihan jika tidak ditentukan
	}
	if amount > remaining {
		return nil, fmt.Errorf("jumlah melebihi sisa tagihan (Rp %.0f)", remaining)
	}
	if amount < remaining && !inv.CanInstallment {
		return nil, errors.New("tagihan ini tidak bisa dicicil")
	}
	if amount < inv.MinimumInstallment {
		return nil, fmt.Errorf("minimal cicilan adalah Rp %.0f", inv.MinimumInstallment)
	}

	// Total yang dibayar via Midtrans = nominal tagihan + 5000 (biaya admin tunai)
	totalWithFee := amount + cashAdminFee

	// Ambil bank_code tenant untuk disisipkan di Order ID
	// Format: NCS{bank_code}{YYYYMMDD}{6 digit random} — contoh: NCS12320260609038291
	bankCode := "000" // default jika gagal ambil tenant
	tenant, _ := u.coreRepo.GetTenantByID(ctx, inv.TenantID)
	if tenant != nil {
		bankCode = tenant.BankCode
	}
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	orderID := fmt.Sprintf("NCS%s%s%06d", bankCode, time.Now().Format("20060102"), r.Intn(1_000_000))

	midtrans.ServerKey = u.midtransKey

	// Ambil data siswa untuk mengisi detail pelanggan (opsional tapi sangat bagus untuk UI Snap)
	var custDetails *midtrans.CustomerDetails
	student, _ := u.coreRepo.GetUserByID(ctx, inv.StudentID)
	if student != nil {
		custDetails = &midtrans.CustomerDetails{
			FName: student.Name,
			Email: student.Email,
		}
	}

	snapReq := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  orderID,
			GrossAmt: int64(totalWithFee),
		},
		CustomerDetail: custDetails,
		Items: &[]midtrans.ItemDetails{
			{
				ID:    inv.ID.String(),
				Price: int64(amount),
				Qty:   1,
				Name:  fmt.Sprintf("Tagihan: %s", inv.InvoiceName),
			},
			{
				ID:    "CASH_ADMIN_FEE",
				Price: int64(cashAdminFee),
				Qty:   1,
				Name:  "Biaya Admin Pembayaran Tunai",
			},
		},
	}

	snapResp, midtransErr := snap.CreateTransaction(snapReq)
	if midtransErr != nil {
		return nil, fmt.Errorf("gagal membuat sesi pembayaran Midtrans: %v", midtransErr.Message)
	}

	// Simpan Midtrans Order ID ke tagihan untuk webhook nanti
	if err := u.repo.UpdateInvoiceMidtransOrderID(ctx, inv.ID, orderID); err != nil {
		return nil, err
	}

	return &domain.CashPaymentResponse{
		SnapToken:   snapResp.Token,
		SnapURL:     snapResp.RedirectURL,
		OrderID:     orderID,
		TotalAmount: totalWithFee,
	}, nil
}

// ProcessMidtransWebhook — Dipanggil saat Midtrans mengirim notifikasi pembayaran berhasil
func (u *billingUsecase) ProcessMidtransWebhook(ctx context.Context, orderID, transactionStatus, grossAmountStr, signatureKey string) error {
	// Verifikasi signature Midtrans: SHA512(order_id + status_code + gross_amount + server_key)
	// Catatan: status_code tidak tersedia di parameter, gunakan yang dari payload
	rawSig := orderID + "200" + grossAmountStr + u.midtransKey
	h := sha512.New()
	h.Write([]byte(rawSig))
	expectedSig := hex.EncodeToString(h.Sum(nil))

	if signatureKey != "" && expectedSig != signatureKey {
		return errors.New("signature Midtrans tidak valid")
	}

	if transactionStatus != "settlement" && transactionStatus != "capture" {
		return nil // Abaikan status lain
	}

	// Cari tagihan berdasarkan order ID
	inv, err := u.repo.GetInvoiceByMidtransOrderID(ctx, orderID)
	if err != nil {
		return err
	}
	if inv == nil {
		return errors.New("tagihan tidak ditemukan untuk order ini")
	}
	if inv.Status == "PAID" {
		return nil // Sudah lunas, abaikan duplikasi
	}

	grossAmount, _ := strconv.ParseFloat(grossAmountStr, 64)
	// Nominal yang masuk ke tagihan = gross - admin fee
	paymentAmount := grossAmount - cashAdminFee
	if paymentAmount <= 0 {
		return errors.New("jumlah pembayaran tidak valid setelah dikurangi biaya admin")
	}

	newPaidTotal := inv.PaidAmount + paymentAmount
	newStatus := resolveInvoiceStatus(inv, newPaidTotal)

	return u.repo.UpdateInvoiceStatus(ctx, inv.ID, newPaidTotal, newStatus)
}

// GetFinanceReport — Admin keuangan mengambil rekap tagihan siswa
func (u *billingUsecase) GetFinanceReport(ctx context.Context, tenantID uuid.UUID, feeTypeID *uuid.UUID) ([]*domain.InvoicePaymentSummary, error) {
	return u.repo.GetFinanceReport(ctx, tenantID, feeTypeID)
}
