import 'package:image_picker/image_picker.dart';

class TripPost {
  final String title;
  final List<XFile> images;
  final List<String> descriptions;

  TripPost({
    required this.title,
    required this.images,
    required this.descriptions,
  });
}

List<TripPost> localTripPosts = [];
