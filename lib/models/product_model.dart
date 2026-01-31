class ProductModel {
  String id; // 🔥 TAMBAH
  String name;
  int price;
  int stock;
  String category;
  String image;
  int count;

  ProductModel({
    required this.id, // 🔥 TAMBAH
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.image,
    this.count = 0,
  });

  factory ProductModel.fromFirestore(
  String id,
  Map<String, dynamic> data,
) {
  return ProductModel(
    id: id, // simpan documentId

    name: data['name']?.toString() ?? '',

    price: (data['price'] as num?)?.toInt() ?? 0,

    stock: (data['stock'] as num?)?.toInt() ?? 0,

    category: data['category'] is Map
        ? data['category']['name']?.toString() ?? 'All'
        : data['category']?.toString() ?? 'All',

    image: data['image'] is Map
        ? data['image']['url']?.toString() ?? ''
        : data['image']?.toString() ?? '',

    count: 0,
  );
}



  // MENGUBAH OBJECT KEMBALI KE MAP (UNTUK DISIMPAN)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'image': image,
      'count': count,
    };
  }
}
