import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vape_store/models/transaction_model.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _filterType = "Harian"; 

  // ===============================
  // FILTER DATA
  // ===============================
  List<TransactionModel> _filterTransactions(List<TransactionModel> list) {
    DateTime now = DateTime.now();

    return list.where((tx) {
      if (_filterType == "Harian") {
        return tx.date.day == now.day &&
            tx.date.month == now.month &&
            tx.date.year == now.year;
      } else {
        return tx.date.month == now.month &&
            tx.date.year == now.year;
      }
    }).toList();
  }

  // ===============================
  // FORMAT RUPIAH
  // ===============================
  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sales History",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _printReport(),
                icon: const Icon(Icons.print, color: Colors.blue, size: 30),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FILTER
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFilterTab("Harian"),
                _buildFilterTab("Bulanan"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===============================
          // DATA DARI FIRESTORE
          // ===============================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child:
                          Text("Belum ada transaksi di periode ini."));
                }

                List<TransactionModel> sales =
                    snapshot.data!.docs.map((doc) {
                  return TransactionModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                final filtered =
                    _filterTransactions(sales);

                if (filtered.isEmpty) {
                  return const Center(
                      child:
                          Text("Belum ada transaksi di periode ini."));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tx = filtered[index];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                            color: Colors.grey.shade300),
                      ),
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.blue.shade50,
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(tx.buyerName,
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                        subtitle: Text(DateFormat(
                                'dd MMM yyyy, HH:mm')
                            .format(tx.date)),
                        trailing: Text(
                          formatCurrency(tx.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // FILTER TAB UI
  // ===============================
  Widget _buildFilterTab(String type) {
    bool isActive = _filterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4)
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // PRINT PLACEHOLDER
  // ===============================
  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text("Fitur Print PDF sedang disiapkan...")),
    );
  }
}
