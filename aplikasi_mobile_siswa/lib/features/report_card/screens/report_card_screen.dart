import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({Key? key}) : super(key: key);

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Kelas';

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
          'Akademik & Rapor',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF055D97),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF055D97),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Rapor Digital'),
                Tab(text: 'Leaderboard'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildRaporTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  Widget _buildRaporTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semester Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Semester Ganjil - 2025/2026',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  'Semester Ganjil - 2025/2026',
                  'Semester Genap - 2024/2025',
                  'Semester Ganjil - 2024/2025',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF055D97),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF055D97).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Rata-rata Nilai',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '89.5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Peringkat Kelas',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Mata Pelajaran Umum (A)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildGradeItem('Pendidikan Agama dan Budi Pekerti', 90, 88, 'A'),
          _buildGradeItem('Pendidikan Pancasila', 88, 86, 'A'),
          _buildGradeItem('Bahasa Indonesia', 92, 90, 'A'),
          _buildGradeItem('Matematika', 89, 88, 'A'),

          const SizedBox(height: 20),
          const Text(
            'Mata Pelajaran Kejuruan (C)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildGradeItem('Administrasi Sistem Jaringan', 90, 95, 'A'),
          _buildGradeItem('Pemrograman Terstruktur', 88, 92, 'A'),
          _buildGradeItem('Pemrograman Perangkat Bergerak', 85, 88, 'B+'),
          _buildGradeItem('Basis Data', 94, 95, 'A'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Dynamic data based on selected filter
    List<Map<String, dynamic>> top3 = [];
    List<Map<String, dynamic>> others = [];

    if (_selectedFilter == 'Kelas') {
      top3 = [
        {'rank': 2, 'name': 'Andi W.', 'score': '88.2', 'height': 100.0, 'color': const Color(0xFF94A3B8)},
        {'rank': 1, 'name': 'Anda (Siswa Bintang)', 'score': '89.5', 'height': 130.0, 'color': const Color(0xFFF59E0B)},
        {'rank': 3, 'name': 'Siti A.', 'score': '87.9', 'height': 90.0, 'color': const Color(0xFFB45309)},
      ];
      others = [
        {'rank': 4, 'name': 'Budi Santoso', 'score': '87.5'},
        {'rank': 5, 'name': 'Rina Mulyani', 'score': '86.8'},
        {'rank': 6, 'name': 'Ahmad Dahlan', 'score': '86.0'},
        {'rank': 30, 'name': 'Faisal Sandy', 'score': '75.5'}, // max 30 siswa
      ];
    } else if (_selectedFilter == 'Jurusan') {
      top3 = [
        {'rank': 2, 'name': 'Anda (Siswa Bintang)', 'score': '89.5', 'height': 100.0, 'color': const Color(0xFF94A3B8)},
        {'rank': 1, 'name': 'Kevin S. (XII RPL 1)', 'score': '91.2', 'height': 130.0, 'color': const Color(0xFFF59E0B)},
        {'rank': 3, 'name': 'Melati P. (XII RPL 3)', 'score': '88.8', 'height': 90.0, 'color': const Color(0xFFB45309)},
      ];
      others = [
        {'rank': 4, 'name': 'Andi W. (XII RPL 2)', 'score': '88.2'},
        {'rank': 5, 'name': 'Siti A. (XII RPL 2)', 'score': '87.9'},
        {'rank': 6, 'name': 'Tono R. (XII RPL 1)', 'score': '87.7'},
        {'rank': 90, 'name': 'Joko A. (XII RPL 3)', 'score': '76.6'}, // 3 kelas x 30 = 90
      ];
    } else {
      top3 = [
        {'rank': 2, 'name': 'Kevin S. (XII RPL 1)', 'score': '91.2', 'height': 100.0, 'color': const Color(0xFF94A3B8)},
        {'rank': 1, 'name': 'Agus B. (XII TKJ 2)', 'score': '92.5', 'height': 130.0, 'color': const Color(0xFFF59E0B)},
        {'rank': 3, 'name': 'Diana K. (XII DKV 1)', 'score': '90.8', 'height': 90.0, 'color': const Color(0xFFB45309)},
      ];
      others = [
        {'rank': 4, 'name': 'Tia F. (XII TT 1)', 'score': '90.1'},
        {'rank': 5, 'name': 'Sisca W. (XII TKJ 1)', 'score': '89.8'},
        {'rank': 6, 'name': 'Anda (Siswa Bintang)', 'score': '89.5'},
        {'rank': 200, 'name': 'Reza O. (XII DKV 2)', 'score': '75.2'},
      ];
    }

    String contextText = _selectedFilter == 'Kelas' ? 'Peringkat di Kelas XII RPL 2 (Total 30 Siswa)' :
                         _selectedFilter == 'Jurusan' ? 'Peringkat Paralel Jurusan RPL (Total 90 Siswa)' :
                         'Peringkat Paralel Seluruh Kelas XII (Total 360 Siswa)';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildRankFilterChip('Kelas')),
              const SizedBox(width: 8),
              Expanded(child: _buildRankFilterChip('Jurusan')),
              const SizedBox(width: 8),
              Expanded(child: _buildRankFilterChip('Paralel')),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              contextText,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Peringkat 1-3
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTopRank(top3[0]['rank'], top3[0]['name'], top3[0]['score'], top3[0]['height'], top3[0]['color']),
              const SizedBox(width: 12),
              _buildTopRank(top3[1]['rank'], top3[1]['name'], top3[1]['score'], top3[1]['height'], top3[1]['color']),
              const SizedBox(width: 12),
              _buildTopRank(top3[2]['rank'], top3[2]['name'], top3[2]['score'], top3[2]['height'], top3[2]['color']),
            ],
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Peringkat Lainnya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...others.map((user) => _buildOtherRank(user['rank'], user['name'], user['score'])).toList(),
        ],
      ),
    );
  }

  Widget _buildRankFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF055D97) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF055D97) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTopRank(int rank, String name, String score, double height, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: rank == 1 ? 40 : 30),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF64748B)),
          ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '$rank',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        )
      ],
      ),
    );
  }

  Widget _buildOtherRank(int rank, String name, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B)),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF055D97)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(String subject, int pengetahuan, int keterampilan, String predikat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSubScore('P:', pengetahuan),
                    const SizedBox(width: 12),
                    _buildSubScore('K:', keterampilan),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: predikat.startsWith('A') ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              predikat,
              style: TextStyle(
                color: predikat.startsWith('A') ? const Color(0xFF059669) : const Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubScore(String label, int score) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          score.toString(),
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
