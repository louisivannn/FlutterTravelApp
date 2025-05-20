import 'package:image_picker/image_picker.dart';

class TripPost {
  final List<XFile> images;
  final List<String> descriptions;

  TripPost({required this.images, required this.descriptions});
}

List<TripPost> localTripPosts = [];
