import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_listing.dart';

class FirestoreService {
  final CollectionReference _listingsCollection =
      FirebaseFirestore.instance.collection('listings');

  // Create a new listing
  Future<void> createListing(PlaceListing listing) async {
    try {
      await _listingsCollection.add(listing.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get all listings stream
  Stream<List<PlaceListing>> getAllListings() {
    return _listingsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlaceListing.fromFirestore(doc))
          .toList();
    });
  }

  // Get listings by user
  Stream<List<PlaceListing>> getListingsByUser(String uid) {
    return _listingsCollection
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlaceListing.fromFirestore(doc))
          .toList();
    });
  }

  // Get listings by category
  Stream<List<PlaceListing>> getListingsByCategory(String category) {
    return _listingsCollection
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlaceListing.fromFirestore(doc))
          .toList();
    });
  }

  // Update listing
  Future<void> updateListing(PlaceListing listing) async {
    try {
      if (listing.id != null) {
        await _listingsCollection.doc(listing.id).update(listing.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _listingsCollection.doc(listingId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get single listing
  Future<PlaceListing?> getListing(String listingId) async {
    try {
      DocumentSnapshot doc = await _listingsCollection.doc(listingId).get();
      if (doc.exists) {
        return PlaceListing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
