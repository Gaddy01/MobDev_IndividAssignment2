import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/listings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/place_listing.dart';
import '../config/app_theme.dart';

class PlaceFormScreen extends StatefulWidget {
  final PlaceListing? listing;

  const PlaceFormScreen({super.key, this.listing});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  Set<PlaceCategory> _selectedCategories = {};
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _contactController.text = widget.listing!.contactNumber;
      _descriptionController.text = widget.listing!.description;
      _latController.text = widget.listing!.latitude.toString();
      _lngController.text = widget.listing!.longitude.toString();
      _selectedCategories = widget.listing!.categories.toSet();
      _selectedLocation = LatLng(
        widget.listing!.latitude,
        widget.listing!.longitude,
      );
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    } catch (e) {
      // Use Kigali City Center as default
      setState(() {
        _selectedLocation = const LatLng(-1.9441, 30.0619);
        _latController.text = '-1.9441';
        _lngController.text = '30.0619';
      });
    }
  }

  void _updateLocationFromCoordinates() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    
    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setState(() {
        _selectedLocation = LatLng(lat, lng);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    }
  }

  Future<void> _saveListing() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location on the map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);

      final listing = PlaceListing(
        id: _isEditing ? widget.listing!.id : null,
        name: _nameController.text.trim(),
        categories: _selectedCategories.toList(),
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        createdBy: authProvider.user!.uid,
        timestamp: _isEditing ? widget.listing!.timestamp : DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await listingsProvider.updateListing(listing);
      } else {
        success = await listingsProvider.createListing(listing);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Listing updated successfully' : 'Listing created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(listingsProvider.errorMessage ?? 'Failed to save listing'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Gradient Header
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: Text(
                    _isEditing ? 'Edit Listing' : 'Add New Listing',
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            
            // Form Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.darkText),
                        decoration: InputDecoration(
                          labelText: 'Place or Service Name',
                          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.lightText),
                          prefixIcon: Icon(Icons.business_rounded, color: AppTheme.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.mediumRadius,
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Categories Section
                    Text(
                      'Categories (select one or more)',
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: 16,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PlaceCategory.values.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppTheme.primaryGradient : null,
                                color: isSelected ? null : AppTheme.lightBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : AppTheme.primaryPurple.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryPurple.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                category.displayName,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: isSelected ? Colors.white : AppTheme.primaryPurple,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Address Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextFormField(
                        controller: _addressController,
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.darkText),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.lightText),
                          prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.mediumRadius,
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Contact Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextFormField(
                        controller: _contactController,
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.darkText),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.lightText),
                          prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.mediumRadius,
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a contact number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Description Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.darkText),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.lightText),
                          prefixIcon: Icon(Icons.description_rounded, color: AppTheme.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.mediumRadius,
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Location Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: AppTheme.headingSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap on map or enter coordinates',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.lightText),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.mediumRadius,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? const LatLng(-1.9441, 30.0619),
                          zoom: 15,
                        ),
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('selected'),
                                  position: _selectedLocation!,
                                ),
                              }
                            : {},
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (position) {
                          setState(() {
                            _selectedLocation = position;
                            _latController.text = position.latitude.toString();
                            _lngController.text = position.longitude.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.mediumRadius,
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: TextFormField(
                              controller: _latController,
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkText),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Latitude',
                                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.lightText),
                                hintText: 'e.g., -1.9441',
                                hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.lightText.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.location_searching, color: AppTheme.primaryPurple, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.mediumRadius,
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final lat = double.tryParse(value);
                                if (lat == null || lat < -90 || lat > 90) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _updateLocationFromCoordinates();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.mediumRadius,
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: TextFormField(
                              controller: _lngController,
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkText),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.lightText),
                                hintText: 'e.g., 30.0619',
                                hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.lightText.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.explore_rounded, color: AppTheme.primaryPurple, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.mediumRadius,
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final lng = double.tryParse(value);
                                if (lng == null || lng < -180 || lng > 180) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _updateLocationFromCoordinates();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    Consumer<ListingsProvider>(
                      builder: (context, listingsProvider, child) {
                        return Container(
                          width: double.infinity,
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
                          child: ElevatedButton(
                            onPressed: listingsProvider.isLoading ? null : _saveListing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.mediumRadius,
                              ),
                            ),
                            child: listingsProvider.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isEditing ? 'Update Listing' : 'Create Listing',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
