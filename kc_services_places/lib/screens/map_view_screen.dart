import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/listings_provider.dart';
import '../models/place_listing.dart';
import 'place_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  final PlaceListing? targetListing;
  
  const MapViewScreen({super.key, this.targetListing});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(-1.9441, 30.0619); // Kigali City Center
  LatLng? _currentPosition;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    
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
      backgroundColor: const Color(0xFF1A2332),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (widget.targetListing != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.targetListing != null 
                              ? 'Directions to:' 
                              : 'Map View',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (widget.targetListing != null)
                          Text(
                            widget.targetListing!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text(
                            'All Listings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_locationPermissionGranted && widget.targetListing == null)
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.amber),
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
                ],
              ),
            ),
            
            // Map
            Expanded(
              child: Consumer<ListingsProvider>(
                builder: (context, listingsProvider, child) {
                  if (widget.targetListing == null) {
                    _createMarkers(listingsProvider.allListings);
                  }

                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: GoogleMap(
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
                    ),
                  );
                },
              ),
            ),
            
            // Navigation button (only for navigation mode)
            if (widget.targetListing != null && _currentPosition != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _launchGoogleMapsNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color(0xFF1A2332),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
