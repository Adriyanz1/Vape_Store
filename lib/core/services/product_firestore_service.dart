import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';

class ProductFirestoreService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  // CREATE PRODUCT
  Future<void> addProduct(ProductModel product) async {
    await productsCollection.add(product.toMap());
  }

  // UPDATE PRODUCT
  Future<void> updateProduct(String id, ProductModel product) async {
    await productsCollection.doc(id).update(product.toMap());
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }

  // READ STREAM
  Stream<List<ProductModel>> getProducts() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
