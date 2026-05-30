import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/report_card/controllers/report_card_controller.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({Key? key}) : super(key: key);

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Kelas';
  final ReportCardController controller = Get.put(ReportCardController());

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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      final report = controller.reportCard.value;
      if (report == null) {
        return const Center(child: Text("Tidak ada data rapor."));
      }

      // Hitung Rata-rata
      double totalScore = 0;
      for (var grade in report.grades) {
        totalScore += grade.score;
      }
      double average = report.grades.isNotEmpty ? totalScore / report.grades.length : 0;

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
                value: '${report.termName} - ${report.academicYear}',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '${report.termName} - ${report.academicYear}',
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
                    children: [
                      const Text(
                        'Rata-rata Nilai',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        average.toStringAsFixed(1),
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
                    children: [
                      const Text(
                        'Peringkat Kelas',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.classRank.toString(),
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
            'Daftar Nilai',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...report.grades.map((g) => _buildGradeItem(g.courseName, g.score, g.predicate)).toList(),
          
          const SizedBox(height: 20),
          const Text(
            'Catatan Wali Kelas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              report.homeroomNotes,
              style: const TextStyle(
                color: Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildLeaderboardTab() {
    return Obx(() {
      if (controller.isLeaderboardLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.leaderboardError.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              controller.leaderboardError.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      final data = controller.leaderboardData;
      if (data.isEmpty) {
        return const Center(child: Text("Belum ada data leaderboard."));
      }

      // Sort data by rank just in case
      data.sort((a, b) => a.rank.compareTo(b.rank));

      // Separate top 3 and others
      final top3Models = data.take(3).toList();
      final othersModels = data.skip(3).toList();

      List<Map<String, dynamic>> top3 = [];
      List<Map<String, dynamic>> others = [];

      for (int i = 0; i < top3Models.length; i++) {
        var m = top3Models[i];
        double height = 100.0;
        Color color = const Color(0xFF94A3B8); // Default rank 2
        
        if (m.rank == 1) {
          height = 130.0;
          color = const Color(0xFFF59E0B);
        } else if (m.rank == 3) {
          height = 90.0;
          color = const Color(0xFFB45309);
        }
        
        top3.add({
          'rank': m.rank,
          'name': m.studentName,
          'className': m.className,
          'score': m.averageScore.toStringAsFixed(1),
          'height': height,
          'color': color,
          'is_me': m.isCurrentUser,
        });
      }

      for (var m in othersModels) {
        others.add({
          'rank': m.rank,
          'name': m.studentName,
          'className': m.className,
          'score': m.averageScore.toStringAsFixed(1),
          'is_me': m.isCurrentUser,
        });
      }

      // Re-order top3 array specifically for UI (rank 2, 1, 3)
      if (top3.length == 3) {
        var temp = top3[0];
        top3[0] = top3[1]; // Rank 2
        top3[1] = temp;    // Rank 1
      }

      String contextText = _selectedFilter == 'Kelas' ? 'Peringkat di Kelas (Sesuai Rapor)' :
                           _selectedFilter == 'Jurusan' ? 'Peringkat Paralel Jurusan' :
                           'Peringkat Paralel Seluruh Angkatan';

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

            if (top3.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (top3.length > 0) _buildTopRank(top3[0]['rank'], top3[0]['name'], top3[0]['className'], top3[0]['score'], top3[0]['height'], top3[0]['color'], top3[0]['is_me']),
                  if (top3.length > 0) const SizedBox(width: 12),
                  if (top3.length > 1) _buildTopRank(top3[1]['rank'], top3[1]['name'], top3[1]['className'], top3[1]['score'], top3[1]['height'], top3[1]['color'], top3[1]['is_me']),
                  if (top3.length > 1) const SizedBox(width: 12),
                  if (top3.length > 2) _buildTopRank(top3[2]['rank'], top3[2]['name'], top3[2]['className'], top3[2]['score'], top3[2]['height'], top3[2]['color'], top3[2]['is_me']),
                ],
              ),
            
            const SizedBox(height: 32),
            
            if (others.isNotEmpty) ...[
              const Text(
                'Peringkat Lainnya',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ...others.map((user) => _buildOtherRank(user['rank'], user['name'], user['className'], user['score'], user['is_me'])).toList(),
            ]
          ],
        ),
      );
    });
  }

  Widget _buildRankFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          controller.fetchLeaderboard(label);
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

  Widget _buildTopRank(int rank, String name, String className, String score, double height, Color color, bool isMe) {
    return Expanded(
      child: Column(
        children: [
          if (isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF055D97),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Anda', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Icon(Icons.emoji_events_rounded, color: color, size: rank == 1 ? 40 : 30),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: isMe ? FontWeight.w900 : FontWeight.bold, fontSize: 13, color: isMe ? const Color(0xFF055D97) : const Color(0xFF0F172A)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (_selectedFilter != 'Kelas') ...[
            const SizedBox(height: 2),
            Text(
              className,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

  Widget _buildOtherRank(int rank, String name, String className, String score, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: isMe ? 2 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isMe ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: isMe ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(fontWeight: isMe ? FontWeight.w900 : FontWeight.bold, fontSize: 15, color: isMe ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Anda', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ],
                ),
                if (_selectedFilter != 'Kelas') ...[
                  const SizedBox(height: 2),
                  Text(
                    className,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            score,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isMe ? const Color(0xFF2563EB) : const Color(0xFF055D97)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(String subject, int score, String predikat) {
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
                    _buildSubScore('Nilai Akhir:', score),
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
