import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import '../../../models/product_model.dart';
import '../../../utils/image_helper.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {

  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();

  String selectedCategory = '';
  File? imageFile;
  String imageBase64 = '';

  bool isLoading = false;

  final productsRef = FirebaseFirestore.instance.collection('products');
  final categoriesRef = FirebaseFirestore.instance.collection('categories');

  // ---------------- INIT ----------------

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      nameC.text = widget.product!.name;
      priceC.text = widget.product!.price.toString();
      stockC.text = widget.product!.stock.toString();
      selectedCategory = widget.product!.category;
      imageBase64 = widget.product!.image;
    }
  }

  // ---------------- PICK IMAGE ----------------

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      imageFile = File(picked.path);

      imageBase64 =
          await ImageHelper.compressAndEncode(imageFile!);

      setState(() {});
    }
  }

  // ---------------- SAVE PRODUCT ----------------

  Future saveProduct() async {
    if (nameC.text.isEmpty ||
        priceC.text.isEmpty ||
        stockC.text.isEmpty ||
        selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data")),
      );
      return;
    }

    setState(() => isLoading = true);

    final data = {
      'name': nameC.text,
      'price': int.parse(priceC.text),
      'stock': int.parse(stockC.text),
      'category': selectedCategory, // SIMPAN ID KATEGORI
      'image': imageBase64,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (widget.product == null) {
      await productsRef.add(data);
    } else {
      await productsRef
          .doc(widget.product!.id)
          .update(data);
    }

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? 'Tambah Produk'
            : 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: imageBase64.isEmpty
                    ? const Icon(Icons.image, size: 50)
                    : Image.memory(
                        base64Decode(imageBase64),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: stockC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // CATEGORY DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: categoriesRef.snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final items = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value:
                      selectedCategory.isEmpty ? null : selectedCategory,
                  hint: const Text("Pilih Kategori"),
                  items: items.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id, // SIMPAN ID
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProduct,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
