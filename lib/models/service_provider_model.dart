class ProviderModel {
  final String name;
  final String specialty;
  final String? imageUrl;
  final double rating;

  ProviderModel({required this.name, required this.specialty, this.imageUrl, required this.rating});

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      name: map['name'],
      specialty: map['specialty'],
      imageUrl: (map['image_url'] != null && map['image_url'].isNotEmpty) 
                      ? map['image_url'] 
                      : 'https://cdn-icons-png.flaticon.com/512/9582/9582626.png',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }
}