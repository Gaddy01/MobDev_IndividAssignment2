import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place_listing.dart';
import '../config/app_theme.dart';
import 'map_view_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceListing listing;

  const PlaceDetailScreen({super.key, required this.listing});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  Future<void> _launchNavigation() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapViewScreen(
          targetListing: widget.listing,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    final url = Uri.parse('tel:${widget.listing.contactNumber}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Color _getCategoryColor() {
    if (widget.listing.categories.isEmpty) return AppTheme.primaryPurple;
    
    final category = widget.listing.categories.first;
    switch (category.toString().split('.').last) {
      case 'cafe':
        return AppTheme.accentOrange;
      case 'restaurant':
        return AppTheme.accentPink;
      case 'hospital':
        return AppTheme.primaryBlue;
      case 'library':
        return AppTheme.primaryPurple;
      case 'park':
        return AppTheme.successGreen;
      default:
        return AppTheme.primaryPurple;
    }
  }

  IconData _getCategoryIcon() {
    if (widget.listing.categories.isEmpty) return Icons.place_rounded;
    
    final category = widget.listing.categories.first;
    switch (category.toString().split('.').last) {
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'park':
        return Icons.park_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppTheme.darkText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor().withOpacity(0.7),
                          _getCategoryColor(),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(),
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.lightBg.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and categories
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.listing.name,
                              style: AppTheme.headingLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.listing.categories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor().withOpacity(0.2),
                                  _getCategoryColor().withOpacity(0.1),
                                ],
                              ),
                              borderRadius: AppTheme.smallRadius,
                              border: Border.all(
                                color: _getCategoryColor().withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              category.displayName,
                              style: AppTheme.bodyMedium.copyWith(
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Description section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.mediumRadius,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('About', style: AppTheme.headingSmall),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.listing.description,
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.lightText,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Contact Information
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.mediumRadius,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.contact_page_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Contact Info', style: AppTheme.headingSmall),
                              ],
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: _makePhoneCall,
                              borderRadius: AppTheme.smallRadius,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightBg,
                                  borderRadius: AppTheme.smallRadius,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      color: _getCategoryColor(),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Phone',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.lightText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.listing.contactNumber,
                                            style: AppTheme.bodyLarge.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.call_rounded,
                                      color: _getCategoryColor(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBg,
                                borderRadius: AppTheme.smallRadius,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: _getCategoryColor(),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Address',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.lightText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.listing.address,
                                          style: AppTheme.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Map
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.mediumRadius,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.map_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Location', style: AppTheme.headingSmall),
                                ],
                              ),
                            ),
                            Container(
                              height: 200,
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              decoration: BoxDecoration(
                                borderRadius: AppTheme.mediumRadius,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ClipRRect(
                                borderRadius: AppTheme.mediumRadius,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      widget.listing.latitude,
                                      widget.listing.longitude,
                                    ),
                                    zoom: 15,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(widget.listing.id ?? ''),
                                      position: LatLng(
                                        widget.listing.latitude,
                                        widget.listing.longitude,
                                      ),
                                    ),
                                  },
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                  },
                                  zoomControlsEnabled: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Navigation Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: AppTheme.mediumRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _launchNavigation,
                          icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                          label: const Text(
                            'Navigate with Map',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.mediumRadius,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
