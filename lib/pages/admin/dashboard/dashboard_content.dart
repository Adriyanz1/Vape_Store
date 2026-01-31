import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vape_store/models/transaction_model.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String _selectedPeriod = "Harian";

  // ===============================
  // FILTER DATA
  // ===============================
  List<TransactionModel> _filteredSales(List<TransactionModel> sales) {
    DateTime now = DateTime.now();

    return sales.where((tx) {
      if (_selectedPeriod == "Harian") {
        return tx.date.day == now.day &&
            tx.date.month == now.month &&
            tx.date.year == now.year;
      } else if (_selectedPeriod == "Mingguan") {
        return tx.date.isAfter(now.subtract(const Duration(days: 7)));
      } else {
        return tx.date.month == now.month &&
            tx.date.year == now.year;
      }
    }).toList();
  }

  // ===============================
  // HITUNG OMZET
  // ===============================
  int _totalRevenue(List<TransactionModel> sales) =>
      sales.fold(0, (sum, item) => sum + item.totalPrice);

  // ===============================
  // HITUNG TERJUAL
  // ===============================
  int _totalSold(List<TransactionModel> sales) {
    int count = 0;
    for (var tx in sales) {
      for (var item in tx.items) {
        count += (item['qty'] as int);
      }
    }
    return count;
  }

  // ===============================
  // PRODUK TERLARIS
  // ===============================
  String _topProduct(List<TransactionModel> sales) {
    if (sales.isEmpty) return "-";

    Map<String, int> productCounts = {};

    for (var tx in sales) {
      for (var item in tx.items) {
        String name = item['name'];
        productCounts[name] =
            (productCounts[name] ?? 0) + (item['qty'] as int);
      }
    }

    var sorted = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada transaksi"));
        }

        // CONVERT FIRESTORE → MODEL
        List<TransactionModel> sales = snapshot.data!.docs.map((doc) {
          return TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        final filtered = _filteredSales(sales);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dashboard",
                  style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // FILTER BUTTONS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterBtn("Harian"),
                    const SizedBox(width: 8),
                    _filterBtn("Mingguan"),
                    const SizedBox(width: 8),
                    _filterBtn("Bulanan"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // STATISTIC CARDS
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Omzet",
                      "Rp ${NumberFormat('#,###', 'id_ID').format(_totalRevenue(filtered))}",
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _statCard(
                      "Terjual",
                      "${_totalSold(filtered)} Item",
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _statCard(
                "Produk Terlaris",
                _topProduct(filtered),
                Colors.blue,
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================
  // WIDGETS
  // ===============================
  Widget _filterBtn(String label) {
    bool isActive = _selectedPeriod == label;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? const Color(0xFF4DB6E7) : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      onPressed: () => setState(() => _selectedPeriod = label),
      child: Text(label),
    );
  }

  Widget _statCard(String title, String value, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}
