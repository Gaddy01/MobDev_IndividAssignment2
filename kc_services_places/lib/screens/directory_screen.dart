import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../models/place_listing.dart';
import '../widgets/place_card.dart';
import '../widgets/category_chip.dart';
import '../config/app_theme.dart';
import 'place_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
      listingsProvider.listenToAllListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kigali City',
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 26,
                                ),
                              ),
                              Text(
                                'Explore amazing places',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTheme.bodyLarge,
                        onChanged: (value) {
                          Provider.of<ListingsProvider>(context, listen: false)
                              .setSearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for places...',
                          hintStyle: AppTheme.bodyMedium,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryPurple),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppTheme.lightText),
                                  onPressed: () {
                                    _searchController.clear();
                                    Provider.of<ListingsProvider>(context, listen: false)
                                        .setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.mediumRadius,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Category chips
              SizedBox(
                height: 50,
                child: Consumer<ListingsProvider>(
                  builder: (context, listingsProvider, child) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(height: 20),
              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nearby Places',
                      style: AppTheme.headingMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Places list
              Expanded(
                child: Consumer<ListingsProvider>(
                  builder: (context, listingsProvider, child) {
                    if (listingsProvider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading places...',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    final listings = listingsProvider.allListings;

                    if (listings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.lightText.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No places found',
                              style: AppTheme.headingMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: PlaceCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailScreen(listing: listing),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
