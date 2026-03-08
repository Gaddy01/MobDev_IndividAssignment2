import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../models/place_listing.dart';
import '../widgets/place_card.dart';
import '../widgets/category_chip.dart';
import 'place_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
      listingsProvider.listenToAllListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Kigali City',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category chips
                  SizedBox(
                    height: 50,
                    child: Consumer<ListingsProvider>(
                      builder: (context, listingsProvider, child) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoryChip(
                              label: 'All',
                              isSelected: listingsProvider.selectedCategory == null,
                              onTap: () {
                                listingsProvider.setCategory(null);
                              },
                            ),
                            CategoryChip(
                              label: 'Cafés',
                              isSelected: listingsProvider.selectedCategory == PlaceCategory.cafe,
                              onTap: () {
                                listingsProvider.setCategory(PlaceCategory.cafe);
                              },
                            ),
                            CategoryChip(
                              label: 'Restaurants',
                              isSelected: listingsProvider.selectedCategory == PlaceCategory.restaurant,
                              onTap: () {
                                listingsProvider.setCategory(PlaceCategory.restaurant);
                              },
                            ),
                            CategoryChip(
                              label: 'Hospitals',
                              isSelected: listingsProvider.selectedCategory == PlaceCategory.hospital,
                              onTap: () {
                                listingsProvider.setCategory(PlaceCategory.hospital);
                              },
                            ),
                            CategoryChip(
                              label: 'Libraries',
                              isSelected: listingsProvider.selectedCategory == PlaceCategory.library,
                              onTap: () {
                                listingsProvider.setCategory(PlaceCategory.library);
                              },
                            ),
                            CategoryChip(
                              label: 'Parks',
                              isSelected: listingsProvider.selectedCategory == PlaceCategory.park,
                              onTap: () {
                                listingsProvider.setCategory(PlaceCategory.park);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      Provider.of<ListingsProvider>(context, listen: false)
                          .setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for a service',
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.search, color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Near You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ListingsProvider>(
                builder: (context, listingsProvider, child) {
                  if (listingsProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    );
                  }

                  final listings = listingsProvider.allListings;

                  if (listings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No places found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return PlaceCard(
                        listing: listing,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlaceDetailScreen(listing: listing),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
