# vape_store
**Vape Store – Aplikasi Kasir**

Vape Store adalah aplikasi kasir berbasis Flutter yang digunakan untuk mencatat transaksi pembelian di toko vape.
Aplikasi ini mendukung dua jenis pengguna dengan hak akses berbeda:
Kasir: langsung masuk untuk mencatat pembelian.
Admin / Pemilik: login untuk mengelola produk dan melihat laporan.

**Fitur**
Login pengguna hanya untuk Admin / Pemilik
Role pengguna:
- Kasir: mencatat transaksi pembelian (langsung masuk)
- Admin / Pemilik: menambah/ubah produk, melihat laporan penjualan
Penyimpanan data transaksi dan produk menggunakan Firebase Firestore
Antarmuka sederhana dan mudah digunakan

**Teknologi yang Digunakan**
Flutter
Firebase Authentication (hanya untuk Admin)
Firebase Firestore Database

**Build APK**
1. Pastikan Flutter SDK sudah terinstal.
2. Clone repository:
 "git clone https://github.com/username/vape-store.git"
3. Masuk ke direktori project:
"cd vape-store"
Install dependency:
"flutter pub get"
Build APK:
"flutter build apk"
File APK akan tersedia di:
"build/app/outputs/flutter-apk/app-release.apk"

**Cara Penggunaan**
**👤 Kasir**
Jalankan aplikasi
Tekan Get Started / Mulai
Masukkan transaksi pembelian pelanggan
Data akan tersimpan otomatis di Firebase Firestore
Tidak dapat mengubah data produk atau melihat laporan

**👑 Admin / Pemilik**
Jalankan aplikasi
Login menggunakan akun Admin / Pemilik
Dapat menambahkan atau mengubah produk
Dapat melihat laporan transaksi penjualan
Semua aktivitas tersimpan di Firebase Firestore

**🔐 Hak Akses Pengguna**
Kasir: input transaksi saja (langsung masuk)
Admin / Pemilik: akses penuh untuk produk dan laporan
Role pengguna diatur melalui sistem role di Firebase Firestore dan aplikasi

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
