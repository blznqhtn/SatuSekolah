package requests

type CreateTenantRequest struct {
	Name    string `json:"name" validate:"required"`
	NPSN    string `json:"npsn"`
	Domain  string `json:"domain" validate:"required"`
	Address string `json:"address"`
	Phone   string `json:"phone"`
	Email   string `json:"email" validate:"email"`
	LogoURL string `json:"logo_url" validate:"url"`
}
