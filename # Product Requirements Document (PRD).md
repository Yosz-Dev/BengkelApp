# Product Requirements Document (PRD)

# POS Bengkel - Sistem Informasi Kasir dan Servis Bengkel Berbasis Android

Version: 1.0

Status: Draft

Platform: Android

---

# 1. Product Overview

POS Bengkel merupakan aplikasi Point of Sale (POS) berbasis Android yang dirancang untuk membantu operasional bengkel motor dalam mengelola transaksi penjualan sparepart, jasa servis, stok barang, pelanggan servis, serta laporan penjualan secara offline.

Aplikasi ditujukan untuk bengkel skala kecil hingga menengah yang membutuhkan sistem kasir sederhana, mudah digunakan, dan tidak bergantung pada koneksi internet.

---

# 2. Problem Statement

Sebagian besar bengkel masih melakukan pencatatan transaksi secara manual sehingga menyebabkan:

* Kesulitan memantau stok sparepart.
* Riwayat transaksi tidak terdokumentasi dengan baik.
* Kesulitan menghitung total pembayaran.
* Kesulitan membuat laporan pendapatan.
* Data pelanggan servis tidak tersimpan dengan rapi.

---

# 3. Product Goal

Membangun aplikasi kasir bengkel yang mampu:

1. Mengelola data sparepart.
2. Mengelola data jasa servis.
3. Melakukan transaksi penjualan dan servis kendaraan.
4. Menyimpan data pelanggan servis.
5. Menyediakan riwayat transaksi.
6. Menampilkan laporan penjualan.
7. Berjalan secara offline pada perangkat Android.

---

# 4. Target User

## Admin

Hak akses:

* Login
* Mengelola seluruh data
* Mengelola transaksi
* Mengakses laporan

## Kasir

Hak akses:

* Login
* Melakukan transaksi
* Melihat data sparepart
* Melihat data jasa
* Melihat riwayat transaksi

---

# 5. Scope Product

## In Scope

### Authentication

* Login
* Logout
* Session login

### Master Data Sparepart

* Tambah sparepart
* Edit sparepart
* Hapus sparepart
* Cari sparepart
* Kelola stok
* Harga jual

### Master Data Jasa

* Tambah jasa
* Edit jasa
* Hapus jasa

### Data Pelanggan Servis

* Tambah pelanggan
* Edit pelanggan
* Hapus pelanggan
* Nomor kendaraan
* Jenis kendaraan

### Transaksi Penjualan

* Penjualan sparepart
* Perhitungan subtotal
* Perhitungan total pembayaran
* Input uang bayar
* Perhitungan kembalian

### Transaksi Servis

* Input pelanggan
* Pilih jasa
* Pilih sparepart yang digunakan
* Hitung total biaya

### Riwayat Transaksi

* Daftar transaksi
* Detail transaksi
* Pencarian transaksi berdasarkan tanggal

### Laporan

* Pendapatan harian
* Pendapatan bulanan
* Laporan stok sparepart

### Profil Bengkel

* Nama bengkel
* Alamat
* Nomor telepon

---

## Out of Scope

Fitur berikut tidak termasuk dalam versi pertama:

* Scan barcode
* Reminder ganti oli
* Integrasi pembayaran digital
* Sinkronisasi cloud
* Multi cabang
* Multi gudang
* Printer Bluetooth
* Notifikasi push
* Sistem reservasi online

---

# 6. Functional Requirements

## FR-01 Login

User dapat login menggunakan username dan password.

---

## FR-02 Manajemen Sparepart

Admin dapat:

* Menambah sparepart
* Mengubah sparepart
* Menghapus sparepart
* Melihat daftar sparepart

---

## FR-03 Manajemen Jasa

Admin dapat:

* Menambah jasa
* Mengubah jasa
* Menghapus jasa

---

## FR-04 Manajemen Pelanggan Servis

Admin dapat:

* Menambah pelanggan
* Mengubah pelanggan
* Menghapus pelanggan

Data pelanggan hanya diperlukan untuk transaksi servis.

---

## FR-05 Transaksi Penjualan Sparepart

Kasir dapat:

* Memilih sparepart
* Menentukan jumlah barang
* Menghitung total pembayaran
* Menginput pembayaran
* Menampilkan kembalian

---

## FR-06 Transaksi Servis

Kasir dapat:

* Memilih pelanggan
* Memilih jasa servis
* Menambahkan sparepart yang digunakan
* Menghasilkan total biaya servis

---

## FR-07 Riwayat Transaksi

User dapat:

* Melihat daftar transaksi
* Melihat detail transaksi
* Mencari transaksi berdasarkan tanggal

---

## FR-08 Laporan

Admin dapat melihat:

* Pendapatan harian
* Pendapatan bulanan
* Stok sparepart

---

# 7. Non Functional Requirements

## Platform

Android

## Framework

Flutter

## Language

Dart

## Database

SQLite

## State Management

Provider

## Session Storage

Shared Preferences

## IDE

Visual Studio Code

## UI Design

Figma

## Architecture

Feature-based architecture

## Operation

Offline-first

---

# 8. Main Modules

1. Authentication Module
2. Dashboard Module
3. Sparepart Module
4. Jasa Servis Module
5. Pelanggan Servis Module
6. Transaction Module
7. History Module
8. Report Module
9. Profile Module

---

# 9. User Flow

Login

↓

Dashboard

↓

Pilih Menu

↓

Data Sparepart / Data Jasa / Data Pelanggan

↓

Transaksi

↓

Riwayat Transaksi

↓

Laporan

↓

Logout

---

# 10. Tech Stack

Frontend:
Flutter

Programming Language:
Dart

Database:
SQLite (sqflite)

State Management:
Provider

Session:
Shared Preferences

Date & Currency Formatting:
intl

PDF Report:
pdf + printing

Design:
Figma

IDE:
Visual Studio Code

Version Control:
Git

Repository:
GitHub

---

# 11. Success Criteria

* Aplikasi dapat berjalan pada Android.
* Seluruh fitur CRUD berjalan dengan baik.
* Transaksi penjualan berhasil dilakukan.
* Transaksi servis berhasil dilakukan.
* Laporan dapat ditampilkan dengan benar.
* Data tersimpan secara lokal menggunakan SQLite.
* Pengujian Black Box menunjukkan seluruh fitur berfungsi sesuai kebutuhan.

---

# 12. Future Enhancement

* Barcode Scanner
* Reminder ganti oli
* Export PDF
* Printer Bluetooth
* Firebase Sync
* Multi User Role
* Dashboard Analitik
* Cloud Backup
* Pembayaran QRIS
* Multi Cabang
