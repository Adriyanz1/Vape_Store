import 'package:flutter/material.dart';
import 'package:vape_store/pages/home/home_page.dart';
import 'package:vape_store/pages/receipt/receipt_page.dart';
import '../../core/services/product_service.dart';
import 'package:vape_store/models/transaction_model.dart';

class SuccessPage extends StatefulWidget { 
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final String buyerName;
  final int paidAmount;

  const SuccessPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.buyerName,
    required this.paidAmount,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  
  @override
  void initState() {
    super.initState();
    // OTOMATIS SIMPAN KE RIWAYAT SAAT HALAMAN MUNCUL
    _saveTransaction();
  }

  void _saveTransaction() {
    final service = ProductService();
    
    // Simpan data transaksi ke riwayat penjualan (Sales History)
    // Fungsi ini juga akan memotong stok di inventory secara otomatis
    service.addTransaction(TransactionModel(
      id: "TRX-${DateTime.now().millisecondsSinceEpoch}",
      buyerName: widget.buyerName,
      items: widget.cartItems,
      totalPrice: widget.totalPrice,
      paidAmount: widget.paidAmount,
      date: DateTime.now(),
    ));
  }

  /// KEMBALIAN
  int get change => widget.paidAmount - widget.totalPrice;

  /// FORMAT RUPIAH
  String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  /// PARSE PRICE → INT (AMAN)
  int parsePrice(dynamic price) {
    if (price is int) return price;
    if (price is num) return price.toInt();
    return int.parse(
      price.toString()
          .replaceAll('Rp. ', '').replaceAll('Rp ', '')
          .replaceAll('.', '').trim(),
    );
  }

  /// PARSE COUNT → INT
  int parseCount(dynamic count) {
    if (count is int) return count;
    if (count is num) return count.toInt();
    return int.tryParse(count.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ===== HEADER =====
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: const Color(0xFF4DB6E7),
            child: Row(
              children: const [
                Spacer(),
                Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Payment Success',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  /// ===== ICON SUCCESS =====
                  Container(
                    width: 120, height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4DB6E7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 70),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Pembayaran Berhasil',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    'Rp ${formatCurrency(widget.totalPrice)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66BB6A),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ===== DETAIL TRANSAKSI =====
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Nama Pembeli', widget.buyerName),
                        _infoRow('Total', 'Rp ${formatCurrency(widget.totalPrice)}'),
                        _infoRow('Dibayar', 'Rp ${formatCurrency(widget.paidAmount)}'),
                        _infoRow(
                          'Kembalian',
                          'Rp ${formatCurrency(change)}',
                          valueColor: Colors.green,
                        ),

                        const Divider(height: 30),

                        /// ===== LIST PRODUK =====
                        ...widget.cartItems
                            .where((item) => parseCount(item['count']) > 0)
                            .map((item) {
                          final int count = parseCount(item['count']);
                          final int price = parsePrice(item['price']);
                          final int subtotal = price * count;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(child: Text('${item['name']} x$count')),
                                Text(
                                  'Rp ${formatCurrency(subtotal)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE9B23E),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ===== BUTTON RECEIPT =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Color(0xFF4DB6E7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReceiptPage(
                              buyerName: widget.buyerName,
                              cartItems: widget.cartItems,
                              totalPrice: widget.totalPrice,
                              paidAmount: widget.paidAmount,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat Nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DB6E7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ===== BUTTON NEW ORDER =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DB6E7),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Pesanan Baru',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor),
          ),
        ],
      ),
    );
  }
}