import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ChildModel {
  final String id;
  final String namaLengkap;
  final String inisial;
  final String kelas;
  final String jurusan;
  final String sekolah;
  final String nisn;
  final String fotoUrl;
  final Color avatarColorStart;
  final Color avatarColorEnd;
  final double persentaseKehadiran;
  final double rataRataNilai;
  final int poinPelanggaran;

  const ChildModel({
    required this.id,
    required this.namaLengkap,
    required this.inisial,
    required this.kelas,
    required this.jurusan,
    this.sekolah = 'Satu Sekolah',
    this.nisn = '',
    this.fotoUrl = '',
    required this.avatarColorStart,
    required this.avatarColorEnd,
    this.persentaseKehadiran = 0,
    this.rataRataNilai = 0,
    this.poinPelanggaran = 0,
  });

  String get namaDepan => namaLengkap.split(' ').isNotEmpty ? namaLengkap.split(' ').first : '';
  String get kelasLengkap => '$kelas · $jurusan';

  ChildModel copyWith({
    String? id,
    String? namaLengkap,
    String? inisial,
    String? kelas,
    String? jurusan,
    String? sekolah,
    String? nisn,
    String? fotoUrl,
    Color? avatarColorStart,
    Color? avatarColorEnd,
    double? persentaseKehadiran,
    double? rataRataNilai,
    int? poinPelanggaran,
  }) {
    return ChildModel(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      inisial: inisial ?? this.inisial,
      kelas: kelas ?? this.kelas,
      jurusan: jurusan ?? this.jurusan,
      sekolah: sekolah ?? this.sekolah,
      nisn: nisn ?? this.nisn,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      avatarColorStart: avatarColorStart ?? this.avatarColorStart,
      avatarColorEnd: avatarColorEnd ?? this.avatarColorEnd,
      persentaseKehadiran: persentaseKehadiran ?? this.persentaseKehadiran,
      rataRataNilai: rataRataNilai ?? this.rataRataNilai,
      poinPelanggaran: poinPelanggaran ?? this.poinPelanggaran,
    );
  }
}

// Dummy data
final List<ChildModel> dummyChildren = [
  const ChildModel(
    id: '1',
    namaLengkap: 'Aditya Pratama',
    inisial: 'AP',
    kelas: 'XII IPA 1',
    jurusan: 'SMK N 1 Cikarang',
    avatarColorStart: AppColors.accent,
    avatarColorEnd: Color(0xFFF5A073),
    persentaseKehadiran: 94,
    rataRataNilai: 87.4,
    poinPelanggaran: 0,
  ),
  const ChildModel(
    id: '2',
    namaLengkap: 'Rina Kartini',
    inisial: 'RK',
    kelas: 'X RPL 2',
    jurusan: 'SMK N 1 Cikarang',
    avatarColorStart: AppColors.teal,
    avatarColorEnd: Color(0xFF38BDF8),
    persentaseKehadiran: 97,
    rataRataNilai: 82.1,
    poinPelanggaran: 5,
  ),
];