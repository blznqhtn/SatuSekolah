import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:aplikasi_mobile_siswa/features/career/screens/pkl_requirement_screen.dart';
import 'package:aplikasi_mobile_siswa/features/career/screens/saved_jobs_screen.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({Key? key}) : super(key: key);

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _wishlist = {};
  String _searchQuery = '';
  String _selectedLocation = 'Semua';
  String _selectedType = 'Semua';

  final List<Map<String, dynamic>> _allJobs = [
    {
      'id': 'pkl_1',
      'company': 'PT Telkom Indonesia',
      'role': 'IT Support Intern',
      'location': 'Bandung',
      'type': 'Magang / PKL',
      'logoUrl': 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=150&h=150&fit=crop',
    },
    {
      'id': 'pkl_2',
      'company': 'Dicoding Indonesia',
      'role': 'Mobile Dev Intern',
      'location': 'Remote',
      'type': 'Magang / PKL',
      'logoUrl': 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=150&h=150&fit=crop',
    },
    {
      'id': 'pkl_3',
      'company': 'Agate Studio',
      'role': 'Game Programmer Intern',
      'location': 'Bandung',
      'type': 'Magang / PKL',
      'logoUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=150&h=150&fit=crop',
    },
    {
      'id': 'job_1',
      'company': 'Gojek Tech',
      'role': 'Junior Software Engineer',
      'location': 'Jakarta',
      'type': 'Full-time',
      'logoUrl': 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=150&h=150&fit=crop',
    },
    {
      'id': 'job_2',
      'company': 'Bank Mandiri IT',
      'role': 'Network Engineer',
      'location': 'Jakarta',
      'type': 'Full-time',
      'logoUrl': 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=150&h=150&fit=crop',
    },
    {
      'id': 'job_3',
      'company': 'Ruangguru',
      'role': 'Backend Developer',
      'location': 'Hybrid',
      'type': 'Contract',
      'logoUrl': 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=150&h=150&fit=crop',
    },
  ];

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Pencarian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Jakarta', 'Bandung', 'Remote', 'Hybrid'].map((loc) {
                    return ChoiceChip(
                      label: Text(loc),
                      selected: _selectedLocation == loc,
                      onSelected: (val) {
                        setBottomSheetState(() => _selectedLocation = loc);
                        setState(() => _selectedLocation = loc);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Tipe', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Magang / PKL', 'Full-time', 'Contract'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (val) {
                        setBottomSheetState(() => _selectedType = type);
                        setState(() => _selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF055D97),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Terapkan Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleWishlist(String id) {
    setState(() {
      if (_wishlist.contains(id)) {
        _wishlist.remove(id);
      } else {
        _wishlist.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Karir & PKL',
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
            icon: const Icon(Icons.bookmark_rounded, color: Color(0xFF055D97)),
            onPressed: () {
              Get.to(() => SavedJobsScreen(
                savedJobIds: _wishlist,
                allJobs: _allJobs,
                onToggleWishlist: _toggleWishlist,
              ))?.then((_) => setState(() {}));
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF055D97),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF055D97),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Informasi PKL'),
                Tab(text: 'Lowongan (Alumni)'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPklTab(),
          _buildCareerTab(),
        ],
      ),
    );
  }

  Widget _buildPklTab() {
    final filteredPkls = _allJobs.where((job) {
      bool isPkl = job['id'].startsWith('pkl');
      bool matchesSearch = job['role'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           job['company'].toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesLocation = _selectedLocation == 'Semua' || job['location'] == _selectedLocation;
      bool matchesType = _selectedType == 'Semua' || job['type'] == _selectedType;
      
      return isPkl && matchesSearch && matchesLocation && matchesType;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF055D97),
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=600&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF055D97).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persiapan PKL 2026',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pastikan semua dokumen persyaratan telah dilengkapi sebelum batas waktu.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const PklRequirementScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF055D97),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cek Persyaratan', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari tempat PKL...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF055D97),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'Rekomendasi Tempat PKL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          if (filteredPkls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Tidak ada tempat PKL yang sesuai pencarian.', style: TextStyle(color: Color(0xFF64748B)))),
            ),
          
          ...filteredPkls.map((job) => _buildJobItem(
            id: job['id'],
            company: job['company'],
            role: job['role'],
            location: job['location'],
            type: job['type'],
            logoUrl: job['logoUrl'],
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCareerTab() {
    final filteredJobs = _allJobs.where((job) {
      bool isJob = job['id'].startsWith('job');
      bool matchesSearch = job['role'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           job['company'].toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesLocation = _selectedLocation == 'Semua' || job['location'] == _selectedLocation;
      bool matchesType = _selectedType == 'Semua' || job['type'] == _selectedType;

      return isJob && matchesSearch && matchesLocation && matchesType;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari lowongan...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF055D97),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Lowongan Terbaru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          if (filteredJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Tidak ada lowongan yang sesuai pencarian.', style: TextStyle(color: Color(0xFF64748B)))),
            ),

          ...filteredJobs.map((job) => _buildJobItem(
            id: job['id'],
            company: job['company'],
            role: job['role'],
            location: job['location'],
            type: job['type'],
            logoUrl: job['logoUrl'],
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildJobItem({
    required String id,
    required String company,
    required String role,
    required String location,
    required String type,
    required String logoUrl,
  }) {
    bool isSaved = _wishlist.contains(id);
    return GestureDetector(
      onTap: () {
        Get.to(() => JobDetailScreen(
          id: id,
          company: company,
          role: role,
          location: location,
          type: type,
          logoUrl: logoUrl,
          isSaved: isSaved,
          onToggleWishlist: () => _toggleWishlist(id),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    image: DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleWishlist(id),
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                    color: isSaved ? const Color(0xFF055D97) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBadge(Icons.location_on_outlined, location),
                const SizedBox(width: 8),
                _buildBadge(Icons.business_center_outlined, type),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class JobDetailScreen extends StatefulWidget {
  final String id;
  final String company;
  final String role;
  final String location;
  final String type;
  final String logoUrl;
  final bool isSaved;
  final VoidCallback onToggleWishlist;

  const JobDetailScreen({
    Key? key,
    required this.id,
    required this.company,
    required this.role,
    required this.location,
    required this.type,
    required this.logoUrl,
    required this.isSaved,
    required this.onToggleWishlist,
  }) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
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
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
              color: _isSaved ? const Color(0xFF055D97) : const Color(0xFF334155),
            ),
            onPressed: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              widget.onToggleWishlist();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Rekrutmen Dummy
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1586281380349-632531db7ed4?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'WE ARE\nHIRING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: DecorationImage(
                            image: NetworkImage(widget.logoUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.role,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.company,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCol(Icons.location_on_outlined, 'Lokasi', widget.location),
                      _buildInfoCol(Icons.business_center_outlined, 'Tipe', widget.type),
                      _buildInfoCol(Icons.attach_money_rounded, 'Gaji', 'Kompetitif'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Deskripsi Pekerjaan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kami mencari kandidat yang termotivasi dan antusias untuk bergabung dengan tim kami. Anda akan dilibatkan dalam berbagai proyek pengembangan yang akan mengasah keterampilan teknis dan soft skill Anda. Kesempatan emas untuk belajar langsung dari profesional berpengalaman.',
                    style: TextStyle(color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Syarat & Kualifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Siswa aktif kelas XI / Alumni SMK jurusan terkait.'),
                  _buildRequirementItem('Memahami dasar-dasar pemrograman dan algoritma.'),
                  _buildRequirementItem('Mampu bekerja sama dalam tim maupun individu.'),
                  _buildRequirementItem('Memiliki inisiatif tinggi dan kemauan belajar yang kuat.'),
                  _buildRequirementItem('Berkomitmen mengikuti program hingga selesai.'),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF055D97),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Lamar Sekarang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCol(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF055D97)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF475569), height: 1.5),
            ),
          )
        ],
      ),
    );
  }
}
