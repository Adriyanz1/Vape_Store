import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String buyerName;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final int paidAmount;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.buyerName,
    required this.items,
    required this.totalPrice,
    required this.paidAmount,
    required this.date,
  });

  // FUNGSI INI YANG KURANG
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      buyerName: map['buyerName'] ?? '',
      // Menangani List dari Firestore dengan aman
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalPrice: map['totalPrice'] ?? 0,
      paidAmount: map['paidAmount'] ?? 0,
      // Firebase menyimpan tanggal sebagai 'Timestamp', kita harus ubah ke 'DateTime'
      date: map['createdAt'] != null
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.now(),
    );
  }
}