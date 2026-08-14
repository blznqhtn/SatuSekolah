import 'package:flutter/material.dart';

enum ActivityType { presensi, rapor, pembayaran, kesehatan, pelanggaran, umum }

enum BadgeVariant { green, red, yellow, blue, orange, gray, purple }

class ActivityModel {
  final String judul;
  final String sub;
  final String waktu;
  final String emoji;
  final Color iconBg;
  final BadgeVariant badge;
  final String badgeLabel;
  final ActivityType tipe;

  const ActivityModel({
    required this.judul,
    required this.sub,
    required this.waktu,
    required this.emoji,
    required this.iconBg,
    required this.badge,
    required this.badgeLabel,
    required this.tipe,
  });
}

class PresensiRecord {
  final String tanggal;
  final String namaHari;
  final String mapel;
  final PresensiStatus status;

  const PresensiRecord({
    required this.tanggal,
    required this.namaHari,
    required this.mapel,
    required this.status,
  });
}

enum PresensiStatus { hadir, sakit, izin, alpha, libur }

class NilaiMapel {
  final String courseId;
  final String mapel;
  final double nilai;
  final String predicate;
  final Color warna;

  const NilaiMapel({
    required this.courseId,
    required this.mapel,
    required this.nilai,
    required this.predicate,
    required this.warna,
  });
}

class PembayaranRecord {
  final String label;
  final String tanggal;
  final String metode;
  final double jumlah;
  final bool lunas;

  const PembayaranRecord({
    required this.label,
    required this.tanggal,
    required this.metode,
    required this.jumlah,
    required this.lunas,
  });
}

class JadwalItem {
  final String jamMulai;
  final String jamSelesai;
  final String mapel;
  final String guru;
  final String ruang;
  final Color warna;
  final bool isBreak;

  const JadwalItem({
    required this.jamMulai,
    required this.jamSelesai,
    required this.mapel,
    required this.guru,
    required this.ruang,
    required this.warna,
    this.isBreak = false,
  });
}

class KalenderEvent {
  final String judul;
  final String tanggal;
  final EventType tipe;
  final Color warna;

  const KalenderEvent({
    required this.judul,
    required this.tanggal,
    required this.tipe,
    required this.warna,
  });
}

enum EventType { ujian, kegiatan, libur, pengumuman }

class GuruModel {
  final String id;
  final String nama;
  final String inisial;
  final String mapel;
  final Color avatarColorStart;
  final Color avatarColorEnd;

  const GuruModel({
    required this.id,
    required this.nama,
    required this.inisial,
    required this.mapel,
    required this.avatarColorStart,
    required this.avatarColorEnd,
  });
}