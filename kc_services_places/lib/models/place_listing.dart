import 'package:cloud_firestore/cloud_firestore.dart';

enum PlaceCategory {
  hospital,
  policeStation,
  library,
  restaurant,
  cafe,
  park,
  touristAttraction,
}

extension PlaceCategoryExtension on PlaceCategory {
  String get displayName {
    switch (this) {
      case PlaceCategory.hospital:
        return 'Hospital';
      case PlaceCategory.policeStation:
        return 'Police Station';
      case PlaceCategory.library:
        return 'Library';
      case PlaceCategory.restaurant:
        return 'Restaurant';
      case PlaceCategory.cafe:
        return 'Café';
      case PlaceCategory.park:
        return 'Park';
      case PlaceCategory.touristAttraction:
        return 'Tourist Attraction';
    }
  }

  static PlaceCategory fromString(String value) {
    switch (value) {
      case 'Hospital':
        return PlaceCategory.hospital;
      case 'Police Station':
        return PlaceCategory.policeStation;
      case 'Library':
        return PlaceCategory.library;
      case 'Restaurant':
        return PlaceCategory.restaurant;
      case 'Café':
      case 'Cafe':
        return PlaceCategory.cafe;
      case 'Park':
        return PlaceCategory.park;
      case 'Tourist Attraction':
        return PlaceCategory.touristAttraction;
      default:
        return PlaceCategory.restaurant;
    }
  }
}

class PlaceListing {
  final String? id;
  final String name;
  final List<PlaceCategory> categories;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;

  PlaceListing({
    this.id,
    required this.name,
    required this.categories,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  factory PlaceListing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle both single category (old data) and multiple categories (new data)
    List<PlaceCategory> categoryList = [];
    if (data['categories'] != null && data['categories'] is List) {
      categoryList = (data['categories'] as List)
          .map((cat) => PlaceCategoryExtension.fromString(cat.toString()))
          .toList();
    } else if (data['category'] != null) {
      // Backwards compatibility for old single category data
      categoryList = [PlaceCategoryExtension.fromString(data['category'] ?? 'Restaurant')];
    } else {
      categoryList = [PlaceCategory.restaurant];
    }
    
    return PlaceListing(
      id: doc.id,
      name: data['name'] ?? '',
      categories: categoryList,
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categories': categories.map((cat) => cat.displayName).toList(),
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  PlaceListing copyWith({
    String? id,
    String? name,
    List<PlaceCategory>? categories,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return PlaceListing(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
