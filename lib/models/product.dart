class Product {
  String? name;
  double? price;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({this.name, this.price, this.createdAt, this.updatedAt});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: (json['price'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }
}
