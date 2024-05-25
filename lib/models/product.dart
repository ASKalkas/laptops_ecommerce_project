class Product {
  String productID;
  String? image;
  String description;
  String cpu;
  String gpu;
  int ram;
  String brand;
  int? discountAmount;
  bool hasDiscount;
  double price;
  int storage;
  String title;
  String vendorID;
  double rating;

  Product({
    required this.productID,
    required this.description,
    required this.cpu,
    required this.gpu,
    required this.ram,
    required this.brand,
    required this.discountAmount,
    required this.hasDiscount,
    required this.price,
    required this.storage,
    required this.title,
    required this.vendorID,
    required this.rating,
    this.image,
  });
}