class ServiceModel {
  final String id;
  final String name;
  final String imageUrl;
  final double? price;

  ServiceModel({required this.id, required this.name, required this.imageUrl, this.price});

  // Factory to convert Supabase Map to Object
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      imageUrl: (map['image_url'] != null && map['image_url'].isNotEmpty) 
                      ? map['image_url'] 
                      : 'https://cdn-icons-png.flaticon.com/512/9582/9582626.png',
      price: (map['price'] != null) ? double.tryParse(map['price'].toString()) : null,
    );
  }
}