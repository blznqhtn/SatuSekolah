// =============================================================================
// library_controller.dart — Fetch Buku & Perpustakaan dari Backend
// =============================================================================
// Endpoint: GET /api/v1/library/books
//           POST /api/v1/library/borrowings/request
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final String? coverUrl;
  final int stock;
  final bool isAvailable;
  final String? isbn;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.isAvailable,
    this.coverUrl,
    this.isbn,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    final stock = json['stock'] as int? ?? json['quantity'] as int? ?? 0;
    return BookItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      category: json['category']?.toString() ?? json['book_type']?.toString() ?? 'Umum',
      stock: stock,
      isAvailable: stock > 0,
      coverUrl: json['cover_url']?.toString() ?? json['image_url']?.toString(),
      isbn: json['isbn']?.toString(),
    );
  }
}

class BorrowingRecord {
  final String id;
  final String bookTitle;
  final String borrowDate;
  final String? dueDate;
  final String? returnDate;
  final String status; // 'ACTIVE', 'RETURNED', 'OVERDUE'

  const BorrowingRecord({
    required this.id,
    required this.bookTitle,
    required this.borrowDate,
    this.dueDate,
    this.returnDate,
    required this.status,
  });

  factory BorrowingRecord.fromJson(Map<String, dynamic> json) {
    return BorrowingRecord(
      id: json['id']?.toString() ?? '',
      bookTitle: json['book_title']?.toString() ??
          json['book']?['title']?.toString() ??
          '',
      borrowDate: json['borrow_date']?.toString() ??
          json['created_at']?.toString() ??
          '',
      dueDate: json['due_date']?.toString(),
      returnDate: json['return_date']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}

class LibraryController extends GetxController {
  final isLoadingBooks = false.obs;
  final isLoadingBorrowings = false.obs;
  final isBorrowing = false.obs;
  final books = <BookItem>[].obs;
  final filteredBooks = <BookItem>[].obs;
  final myBorrowings = <BorrowingRecord>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final categories = <String>['Semua'].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    // Auto-filter saat query berubah
    debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedCategory, (_) => _applyFilter());
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchBooks(), fetchMyBorrowings()]);
  }

  Future<void> fetchBooks() async {
    isLoadingBooks.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.dio.get('/library/books');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }

        books.value = list
            .map((item) => BookItem.fromJson(item as Map<String, dynamic>))
            .toList();

        // Kumpulkan kategori unik
        final cats = books.map((b) => b.category).toSet().toList()..sort();
        categories.value = ['Semua', ...cats];

        _applyFilter();
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal memuat buku.';
    } finally {
      isLoadingBooks.value = false;
    }
  }

  Future<void> fetchMyBorrowings() async {
    isLoadingBorrowings.value = true;
    try {
      // Backend tidak punya endpoint khusus untuk melihat peminjaman saya,
      // kita minta via query param atau gunakan endpoint generik
      final response =
          await ApiService.dio.get('/library/borrowings/request');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        myBorrowings.value = list
            .map((item) =>
                BorrowingRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Silent fail
    } finally {
      isLoadingBorrowings.value = false;
    }
  }

  /// Cari buku dan filter berdasarkan kategori.
  void search(String query) {
    searchQuery.value = query;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void _applyFilter() {
    var result = books.toList();

    if (selectedCategory.value != 'Semua') {
      result = result
          .where((b) => b.category == selectedCategory.value)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q))
          .toList();
    }

    filteredBooks.value = result;
  }

  /// Ajukan peminjaman buku.
  Future<bool> requestBorrow(String bookId) async {
    isBorrowing.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.dio.post(
        '/library/borrowings/request',
        data: {'book_id': bookId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyBorrowings();
        return true;
      }
      return false;
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['error']?.toString() ??
          'Gagal meminjam buku.';
      return false;
    } finally {
      isBorrowing.value = false;
    }
  }
}
