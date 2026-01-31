import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final int paidAmount;
  final String buyerName;

  const ReceiptPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.paidAmount,
    required this.buyerName,
  });

  /// KEMBALIAN
  int get change => paidAmount - totalPrice;

  /// FORMAT RUPIAH
  String formatCurrency(int amount) {
    return NumberFormat('#,###', 'id_ID')
        .format(amount)
        .replaceAll(',', '.');
  }

  /// PARSE PRICE → INT (AMAN DARI STRING / NUM)
  int parsePrice(dynamic price) {
    if (price is int) return price;
    if (price is num) return price.toInt();

    return int.parse(
      price
          .toString()
          .replaceAll('Rp. ', '')
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .trim(),
    );
  }

  /// PARSE COUNT → INT (FIX ERROR NUM)
  int parseCount(dynamic count) {
    if (count is int) return count;
    if (count is num) return count.toInt();
    return int.tryParse(count.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nota Pembayaran'),
        backgroundColor: const Color(0xFF4DB6E7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== HEADER =====
            Center(
              child: Column(
                children: const [
                  Text(
                    'VAPE STORE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('--- STRUK KASIR ---'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Nama : $buyerName'),
            Text(
              'Tanggal : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            ),

            const Divider(height: 30),

            /// ===== LIST ITEM =====
            ...cartItems
                .where((item) => parseCount(item['count']) > 0)
                .map((item) {
              final int count = parseCount(item['count']);
              final int price = parsePrice(item['price']);
              final int subtotal = price * count;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item['name']} x$count'),
                    ),
                    Text(formatCurrency(subtotal)),
                  ],
                ),
              );
            }).toList(),

            const Divider(height: 30),

            /// ===== TOTAL =====
            _row('Total', formatCurrency(totalPrice)),
            _row('Bayar', formatCurrency(paidAmount)),
            _row('Kembali', formatCurrency(change)),

            const Spacer(),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
