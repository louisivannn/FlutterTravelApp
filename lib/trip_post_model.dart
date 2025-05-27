class TripPost {
  final String title;
  final List<String> imageUrls; // URLs of uploaded images
  final List<String> descriptions;
  final String userId;

  TripPost({
    required this.title,
    required this.imageUrls,
    required this.descriptions,
    required this.userId,
  });

  // From Firestore (map) to TripPost
  factory TripPost.fromFirestore(Map<String, dynamic> map) {
    return TripPost(
      title: map['title'] ?? '',
      imageUrls: _ensureListOfString(map['images']),
      descriptions: _ensureListOfString(map['description']),
      userId: map['userId'] ?? '',
    );
  }

  // Helper method
  static List<String> _ensureListOfString(dynamic data) {
    if (data == null) return [];
    if (data is String) return [data]; // Convert single string to list
    if (data is Iterable) return List<String>.from(data);

    return [];

  }



  // To Firestore (TripPost to map)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrls': imageUrls,
      'descriptions': descriptions,
      'userId': userId,
    };
  }
}
