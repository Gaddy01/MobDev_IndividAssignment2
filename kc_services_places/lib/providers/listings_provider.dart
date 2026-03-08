import 'package:flutter/foundation.dart';
import '../models/place_listing.dart';
import '../services/firestore_service.dart';

class ListingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<PlaceListing> _allListings = [];
  List<PlaceListing> _filteredListings = [];
  List<PlaceListing> _myListings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  PlaceCategory? _selectedCategory;

  List<PlaceListing> get allListings => _filteredListings;
  List<PlaceListing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  PlaceCategory? get selectedCategory => _selectedCategory;

  void listenToAllListings() {
    _firestoreService.getAllListings().listen((listings) {
      _allListings = listings;
      _applyFilters();
      notifyListeners();
    });
  }

  void listenToMyListings(String uid) {
    _firestoreService.getListingsByUser(uid).listen((listings) {
      _myListings = listings;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(PlaceCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredListings = _allListings;

    // Apply category filter
    if (_selectedCategory != null) {
      _filteredListings = _filteredListings
          .where((listing) => listing.categories.contains(_selectedCategory))
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredListings = _filteredListings
          .where((listing) =>
              listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              listing.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Future<bool> createListing(PlaceListing listing) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.createListing(listing);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create listing: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(PlaceListing listing) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateListing(listing);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update listing: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteListing(listingId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete listing: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
