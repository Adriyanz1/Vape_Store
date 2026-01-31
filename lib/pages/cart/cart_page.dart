import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vape_store/pages/success_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();

  // ================= FORMAT RUPIAH =================
  String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  // ================= PARSE HARGA =================
  int parsePrice(dynamic price) {
    if (price is int) return price;
    if (price is num) return price.toInt();
    return int.tryParse(
            price.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  // ================= SIMPAN TRANSAKSI + UPDATE STOK =================
  Future<void> saveTransactionAndUpdateStock(
      String buyer, int paid, int total) async {
    final firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();

    final trxRef = firestore.collection('transactions').doc();
    List<Map<String, dynamic>> items = widget.cartItems.map((item) {
      final int price = parsePrice(item['price']);
      final int count = item['count'] is int ? item['count'] : 0;
      return {
        'productId': item['id'], // HARUS ADA
        'name': item['name'],
        'price': price,
        'qty': count,
        'subtotal': price * count,
      };
    }).toList();

    int change = paid - total;

    batch.set(trxRef, {
      'buyerName': buyer,
      'totalPrice': total,
      'paidAmount': paid,
      'change': change,
      'items': items,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update stok produk
    for (var item in widget.cartItems) {
      final productRef = firestore.collection('products').doc(item['id']);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item['count']),
      });
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.cartItems.fold(0, (sum, item) {
      final int price = parsePrice(item['price']);
      final int count = item['count'] is int ? item['count'] : 0;
      return sum + (price * count);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF4DB6E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildProductItem(widget.cartItems[index]);
                        },
                      ),
                    ),
                    _buildOrderSection(totalPrice),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.shopping_cart, color: Colors.white),
          const SizedBox(width: 10),
          const Text(
            'Keranjang',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _buildProductItem(Map<String, dynamic> item) {
    final int price = parsePrice(item['price']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Rp ${formatCurrency(price)}',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
          Text('x${item['count']}'),
        ],
      ),
    );
  }

  // ================= TOTAL =================
  Widget _buildOrderSection(int totalPrice) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18)),
              Text(
                'Rp ${formatCurrency(totalPrice)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _showPaymentDialog(totalPrice),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG BAYAR =================
  void _showPaymentDialog(int totalPrice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _buyerController,
              decoration: const InputDecoration(labelText: 'Nama Pembeli (Opsional)'),
            ),
            TextField(
              controller: _paidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Uang Bayar'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final buyer = _buyerController.text.isEmpty ? "-" : _buyerController.text;
              final paid = int.tryParse(_paidController.text) ?? 0;

              if (paid < totalPrice) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Uang bayar kurang")),
                );
                return;
              }

              await saveTransactionAndUpdateStock(buyer, paid, totalPrice);

              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuccessPage(
                    cartItems: widget.cartItems,
                     totalPrice: totalPrice,
                    buyerName: buyer,
                    paidAmount: paid,
                  ),
                ),
              );
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}
