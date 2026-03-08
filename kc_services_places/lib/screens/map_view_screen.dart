import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/listings_provider.dart';
import '../models/place_listing.dart';
import '../config/app_theme.dart';
import 'place_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  final PlaceListing? targetListing;
  
  const MapViewScreen({super.key, this.targetListing});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(-1.9441, 30.0619); // Kigali City Center
  LatLng? _currentPosition;
  bool _locationPermissionGranted = false;
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
    
    // If target listing is provided, focus on it
    if (widget.targetListing != null) {
      _initialPosition = LatLng(
        widget.targetListing!.latitude,
        widget.targetListing!.longitude,
      );
    }
    
    _checkLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
      listingsProvider.listenToAllListings();
      
      // Zoom to target listing if provided
      if (widget.targetListing != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 16),
        );
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        if (widget.targetListing == null) {
          _initialPosition = _currentPosition!;
        }
      });
      
      if (widget.targetListing == null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 14),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _launchGoogleMapsNavigation() async {
    if (widget.targetListing == null || _currentPosition == null) return;

    final destination = '${widget.targetListing!.latitude},${widget.targetListing!.longitude}';
    final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createMarkers(List<PlaceListing> listings) {
    _markers = listings.map((listing) {
      // Use first category for marker color, or default if empty
      final primaryCategory = listing.categories.isNotEmpty 
          ? listing.categories.first 
          : PlaceCategory.restaurant;
      
      // Join all category names for the snippet
      final categoriesText = listing.categories
          .map((cat) => cat.displayName)
          .join(', ');
      
      return Marker(
        markerId: MarkerId(listing.id ?? ''),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: categoriesText.isNotEmpty ? categoriesText : 'No category',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlaceDetailScreen(listing: listing),
              ),
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(primaryCategory),
        ),
      );
    }).toSet();
  }

  double _getMarkerColor(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.hospital:
        return BitmapDescriptor.hueRed;
      case PlaceCategory.policeStation:
        return BitmapDescriptor.hueBlue;
      case PlaceCategory.library:
        return BitmapDescriptor.hueViolet;
      case PlaceCategory.restaurant:
        return BitmapDescriptor.hueOrange;
      case PlaceCategory.cafe:
        return BitmapDescriptor.hueYellow;
      case PlaceCategory.park:
        return BitmapDescriptor.hueGreen;
      case PlaceCategory.touristAttraction:
        return BitmapDescriptor.hueCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          // Map
          Consumer<ListingsProvider>(
            builder: (context, listingsProvider, child) {
              if (widget.targetListing == null) {
                _createMarkers(listingsProvider.allListings);
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: widget.targetListing != null ? 16 : 12,
                ),
                markers: _markers,
                myLocationEnabled: _locationPermissionGranted,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Zoom to target listing if provided
                  if (widget.targetListing != null) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_initialPosition, 16),
                      );
                    });
                  }
                },
              );
            },
          ),
          
          // Top header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: AppTheme.mediumRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (widget.targetListing != null)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.targetListing != null 
                                  ? 'Navigate to' 
                                  : 'Map View',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (widget.targetListing != null)
                              Text(
                                widget.targetListing!.name,
                                style: AppTheme.headingSmall.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                'All Places',
                                style: AppTheme.headingSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_locationPermissionGranted && widget.targetListing == null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.my_location_rounded, color: AppTheme.primaryPurple),
                            onPressed: () async {
                              try {
                                Position position = await Geolocator.getCurrentPosition();
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(position.latitude, position.longitude),
                                    14,
                                  ),
                                );
                              } catch (e) {
                                // Handle error
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom navigation button (only for navigation mode)
          if (widget.targetListing != null && _currentPosition != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
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
                      onPressed: _launchGoogleMapsNavigation,
                      icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                      label: const Text(
                        'Open in Google Maps',
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
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
