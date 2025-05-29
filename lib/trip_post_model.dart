class TripPost {
  final String title;
  final List<String> imageUrls; // URLs of uploaded images
  final List<String> descriptions;
  final String userId;
  final String username;
  final String profileImageUrl;
  final String postId;

  TripPost({
    required this.title,
    required this.imageUrls,
    required this.descriptions,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.postId,
  });

  // From Firestore (map) to TripPost
  factory TripPost.fromFirestore(Map<String, dynamic> data) {
    List<String> images = [];
    if (data['images'] != null) {
      if (data['images'] is List) {
        images = List<String>.from(data['images']);
      } else if (data['images'] is String) {
        images = [data['images']];
      }
    }

    List<String> descriptions = [];
    if (data['description'] != null) {
      if (data['description'] is List) {
        descriptions = List<String>.from(data['description']);
      } else if (data['description'] is String) {
        descriptions = [data['description']];
      }
    }

    if (descriptions.length < images.length) {
      descriptions = List.generate(
        images.length,
        (index) => index < descriptions.length ? descriptions[index] : '',
      );
    }

    return TripPost(
      title: data['title'] ?? '',
      imageUrls: images,
      descriptions: descriptions,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profile_image'] ?? '',
      postId: data['postId'] ?? '',
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
