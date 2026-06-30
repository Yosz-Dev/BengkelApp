/// Ringkasan pendapatan pada satu periode (harian / bulanan).
class RingkasanPendapatan {
  final double totalPenjualan;
  final double totalServis;
  final int jumlahTransaksi;

  const RingkasanPendapatan({
    this.totalPenjualan = 0,
    this.totalServis = 0,
    this.jumlahTransaksi = 0,
  });

  double get total => totalPenjualan + totalServis;
}

/// Pendapatan teragregasi per hari (dipakai pada rincian laporan bulanan).
class PendapatanPerHari {
  final DateTime tanggal;
  final double total;
  final int jumlah;

  const PendapatanPerHari({
    required this.tanggal,
    required this.total,
    required this.jumlah,
  });
}
