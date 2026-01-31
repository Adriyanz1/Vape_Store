import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vape_store/models/product_model.dart';
import 'package:vape_store/pages/cart/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // LIST PRODUK DARI FIRESTORE
  List<ProductModel> allProducts = [];

  // MAP UNTUK MENYIMPAN JUMLAH BERDASARKAN ID PRODUK
  final Map<String, int> cartCount = {};

  // Mapping kategori ke Firestore ID
  final Map<String, String> categoryMap = {
    'Pod': 'C001',
    'Liquid': 'C002',
    'Mod': 'C003',
    'Cartridge': 'C004',
  };

  // FORMAT RUPIAH
  String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  // TOTAL ITEM DI KERANJANG
  int get totalItemsInCart {
    return cartCount.values.fold(0, (sum, item) => sum + item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 5),
            _buildCategoryList(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Produk belum tersedia"));
                  }

                  // Konversi data ke ProductModel
                  allProducts = snapshot.data!.docs.map((doc) {
                    final product = ProductModel.fromFirestore(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );

                    // Ambil count sebelumnya
                    product.count = cartCount[product.id] ?? 0;
                    return product;
                  }).toList();

                  // FILTER
                  List<ProductModel> displayedProducts = allProducts.where((product) {
                    final matchesCategory =
                        selectedCategory == 'All' ||
                        product.category == categoryMap[selectedCategory];
                    final matchesSearch =
                        product.name.toLowerCase().contains(searchQuery.toLowerCase());
                    return matchesCategory && matchesSearch;
                  }).toList();

                  return Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6FBFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: displayedProducts.isEmpty
                        ? const Center(child: Text("Barang tidak ditemukan.."))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              var product = displayedProducts[index];
                              return productCard(
                                product,
                                onAdd: () {
                                  if (product.count < product.stock) {
                                    setState(() {
                                      product.count++;
                                      cartCount[product.id] = product.count;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Stok tidak mencukupi"),
                                      ),
                                    );
                                  }
                                },
                                onRemove: () {
                                  if (product.count > 0) {
                                    setState(() {
                                      product.count--;
                                      cartCount[product.id] = product.count;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildFloatingCart(),
      bottomNavigationBar: const BottomAppBar(color: Colors.transparent, height: 10),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF4DB6E7), size: 35),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6E7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Search..",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORY LIST
  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          categoryItem(Icons.grid_view_rounded, 'All'),
          categoryItem(Icons.ev_station_rounded, 'Pod'),
          categoryItem(Icons.opacity_rounded, 'Liquid'),
          categoryItem(Icons.smoking_rooms_rounded, 'Mod'),
          categoryItem(Icons.electrical_services_rounded, 'Cartridge'),
        ],
      ),
    );
  }

  // DRAWER
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4DB6E7)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: Color(0xFF4DB6E7)),
            ),
            accountName: Text("Kasir Vape Store"),
            accountEmail: Text("kasir.vape@email.com"),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Keluar"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // FLOATING CART
  Widget buildFloatingCart() {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: InkWell(
        onTap: () async {
          final cartItems = allProducts
              .where((p) => p.count > 0)
              .map((p) {
            return {
              'id': p.id, // <- penting untuk update stok
              'name': p.name,
              'price': p.price,
              'count': p.count,
              'image': p.image,
            };
          }).toList();

          if (cartItems.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage(cartItems: cartItems)),
            );

            cartCount.clear();
            for (var p in allProducts) {
              p.count = 0;
            }
            setState(() {});
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFF4DB6E7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            if (totalItemsInCart > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$totalItemsInCart",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // CATEGORY ITEM
  Widget categoryItem(IconData icon, String label) {
    bool isActive = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? const Color(0xFF4DB6E7) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(icon, color: const Color(0xFF4DB6E7)),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  // PRODUCT CARD
  Widget productCard(ProductModel product,
      {required VoidCallback onAdd, required VoidCallback onRemove}) {
    Uint8List? bytes;
    if (product.image.isNotEmpty) {
      bytes = base64Decode(product.image);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bytes != null
                ? Image.memory(
                    bytes,
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_outlined),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Stok ${product.stock}"),
                Text("Rp ${formatCurrency(product.price)}"),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(onTap: onRemove, child: const Icon(Icons.remove)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("${product.count}"),
              ),
              GestureDetector(onTap: onAdd, child: const Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );
  }
}
