import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Set<String> _savedBooks = {};

  void _toggleSaved(String title) {
    setState(() {
      if (_savedBooks.contains(title)) {
        _savedBooks.remove(title);
      } else {
        _savedBooks.add(title);
      }
    });
  }

  final List<Map<String, dynamic>> _allBooks = [
    {
      'title': 'Bumi Manusia',
      'author': 'Pramoedya A. Toer',
      'category': 'Sejarah',
      'imageUrl': 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=300&auto=format&fit=crop',
      'rating': 4.8,
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'category': 'Pengembangan Diri',
      'imageUrl': 'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=300&auto=format&fit=crop',
      'rating': 4.9,
    },
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'category': 'Sains',
      'imageUrl': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=300&auto=format&fit=crop',
      'rating': 4.7,
    },
    {
      'title': 'Laskar Pelangi',
      'author': 'Andrea Hirata',
      'category': 'Fiksi',
      'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300&auto=format&fit=crop',
      'rating': 4.9,
    },
    {
      'title': 'Dasar Pemrograman Web',
      'author': 'Budi Raharjo',
      'category': 'Teknologi',
      'imageUrl': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=300&auto=format&fit=crop',
      'rating': 4.6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Filter books based on search and category
    final filteredBooks = _allBooks.where((book) {
      final matchCategory = _selectedCategory == 'Semua' || book['category'] == _selectedCategory;
      final matchSearch = book['title'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          book['author'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'E-Perpus',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _savedBooks.isNotEmpty,
              label: Text(_savedBooks.length.toString()),
              backgroundColor: const Color(0xFF055D97),
              child: const Icon(Icons.bookmarks_outlined, color: Color(0xFF334155)),
            ),
            onPressed: () {
              Get.to(() => SavedBooksScreen(
                savedTitles: _savedBooks,
                allBooks: _allBooks,
                onToggleSaved: _toggleSaved,
              ))?.then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari judul, penulis...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Kategori
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryChip('Semua'),
                  _buildCategoryChip('Fiksi'),
                  _buildCategoryChip('Sains'),
                  _buildCategoryChip('Sejarah'),
                  _buildCategoryChip('Teknologi'),
                  _buildCategoryChip('Pengembangan Diri'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Result
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _searchQuery.isNotEmpty || _selectedCategory != 'Semua' ? 'Hasil Pencarian' : 'Rekomendasi Untukmu',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (filteredBooks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Text('Tidak ada buku yang ditemukan.', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
              )
            else
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return _buildBookCard(
                      title: book['title'],
                      author: book['author'],
                      category: book['category'],
                      imageUrl: book['imageUrl'],
                      rating: book['rating'],
                      isSaved: _savedBooks.contains(book['title']),
                      onToggleSaved: () => _toggleSaved(book['title']),
                    );
                  },
                ),
              ),

            // Hide continue reading if searching
            if (_searchQuery.isEmpty && _selectedCategory == 'Semua') ...[
              const SizedBox(height: 32),
              // Sedang Dibaca (Continue Reading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sedang Dibaca',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF055D97),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const BookDetailScreen(
                          title: 'Laskar Pelangi',
                          author: 'Andrea Hirata',
                          category: 'Fiksi',
                          rating: 4.9,
                          imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=200&auto=format&fit=crop',
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 85,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFF1F5F9),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=200&auto=format&fit=crop'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Laskar Pelangi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Andrea Hirata',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: const LinearProgressIndicator(
                                            value: 0.65,
                                            backgroundColor: Color(0xFFF1F5F9),
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF055D97)),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '65%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _selectedCategory = label;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF055D97) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF055D97) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard({
    required String title,
    required String author,
    required String category,
    required String imageUrl,
    required double rating,
    required bool isSaved,
    required VoidCallback onToggleSaved,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BookDetailScreen(
          title: title,
          author: author,
          category: category,
          rating: rating,
          imageUrl: imageUrl,
          isSaved: isSaved,
          onToggleSaved: onToggleSaved,
        ));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF1F5F9),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleSaved,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isSaved ? const Color(0xFF055D97) : const Color(0xFF94A3B8),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              author,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================
// Halaman Buku Tersimpan
// ========================
class SavedBooksScreen extends StatelessWidget {
  final Set<String> savedTitles;
  final List<Map<String, dynamic>> allBooks;
  final Function(String) onToggleSaved;

  const SavedBooksScreen({
    Key? key,
    required this.savedTitles,
    required this.allBooks,
    required this.onToggleSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedBooks = allBooks.where((b) => savedTitles.contains(b['title'])).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Buku Tersimpan',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: savedBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmarks_outlined, size: 80, color: const Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada buku yang disimpan',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketuk ikon bookmark di kartu buku untuk menyimpannya.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: savedBooks.length,
              itemBuilder: (context, index) {
                final book = savedBooks[index];
                return GestureDetector(
                  onTap: () => Get.to(() => BookDetailScreen(
                    title: book['title'],
                    author: book['author'],
                    category: book['category'],
                    rating: book['rating'],
                    imageUrl: book['imageUrl'],
                  )),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(book['imageUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(book['author'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                child: Text(book['category'], style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onToggleSaved(book['title']);
                            Get.snackbar('Dihapus', '"${book['title']}" dihapus dari simpanan', backgroundColor: Colors.white);
                          },
                          child: const Icon(Icons.bookmark_rounded, color: Color(0xFF055D97)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String category;
  final double rating;
  final String imageUrl;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  const BookDetailScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.category,
    required this.rating,
    required this.imageUrl,
    this.isSaved = false,
    this.onToggleSaved,
  }) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Detail Buku', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? const Color(0xFF055D97) : const Color(0xFF334155),
            ),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              if (widget.onToggleSaved != null) widget.onToggleSaved!();
              Get.snackbar(
                _isSaved ? 'Disimpan' : 'Dihapus',
                _isSaved ? '"${widget.title}" ditambahkan ke simpanan' : '"${widget.title}" dihapus dari simpanan',
                backgroundColor: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.author,
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                const SizedBox(width: 4),
                Text(
                  '${widget.rating}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.category, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sinopsis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buku ini membahas berbagai aspek penting tentang topik yang diangkat. Cocok dibaca untuk menambah wawasan dan referensi pembelajaran sehari-hari. Penulis menggambarkan situasi dengan sangat mendalam sehingga pembaca bisa langsung memahaminya.',
              style: TextStyle(color: Color(0xFF475569), height: 1.5),
            ),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_book_rounded, size: 20),
                    label: const Text('Mulai Baca'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF055D97),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.rate_review_rounded, size: 20),
                    label: const Text('Beri Ulasan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF055D97),
                      side: const BorderSide(color: Color(0xFF055D97)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ulasan Pembaca',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewItem('Siswa Bintang', 5, 'Buku yang sangat bagus dan mudah dipahami!'),
            _buildReviewItem('Andi Wijaya', 4, 'Cukup bermanfaat untuk bahan referensi tugas sekolah.'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String name, int starCount, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFCBD5E1),
                radius: 16,
                child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: index < starCount ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                )),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
        ],
      ),
    );
  }
}
