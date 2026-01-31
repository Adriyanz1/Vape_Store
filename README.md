## Vape Store – Aplikasi Kasir

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
1. Flutter
2. Firebase Authentication (hanya untuk Admin)
3. Firebase Firestore Database

**Build APK**
1. Pastikan Flutter SDK sudah terinstal.
2. Clone repository:
 "git clone https://github.com/username/vape-store.git"
3. Masuk ke direktori project:
"cd vape-store"
4. Install dependency:
"flutter pub get"
5. Build APK:
"flutter build apk"
6. File APK akan tersedia di:
"build/app/outputs/flutter-apk/app-release.apk"

**Cara Penggunaan**

**👤 Kasir**
1. Jalankan aplikasi
2. Tekan Get Started / Mulai
3. Masukkan transaksi pembelian pelanggan
4. Data akan tersimpan otomatis di Firebase Firestore
5. Tidak dapat mengubah data produk atau melihat laporan

**👑 Admin / Pemilik**
1. Jalankan aplikasi
2. Login menggunakan akun Admin / Pemilik
3. Dapat menambahkan atau mengubah produk
4. Dapat melihat laporan transaksi penjualan
5. Semua aktivitas tersimpan di Firebase Firestore

**🔐 Hak Akses Pengguna**
1. Kasir: input transaksi saja (langsung masuk)
2. Admin / Pemilik: akses penuh untuk produk dan laporan

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
