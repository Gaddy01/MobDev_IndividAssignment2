import 'package:flutter/material.dart';
import '../models/place_listing.dart';
import '../config/app_theme.dart';

class PlaceCard extends StatefulWidget {
  final PlaceListing listing;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaceCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryPurple,
      AppTheme.primaryBlue,
      AppTheme.accentPink,
      AppTheme.accentOrange,
    ];
    return colors[index % colors.length];
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.mediumRadius,
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppTheme.mediumRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with gradient overlay
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(0).withOpacity(0.7),
                            _getCategoryColor(1).withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(),
                          size: 50,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    // Category chips overlay
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: AppTheme.smallRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.listing.categories.isNotEmpty 
                              ? widget.listing.categories.first.displayName
                              : 'Place',
                          style: AppTheme.bodySmall.copyWith(
                            color: _getCategoryColor(0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.listing.name,
                              style: AppTheme.headingSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!widget.showActions)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppTheme.lightText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.listing.address,
                              style: AppTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.showActions) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onEdit,
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryPurple,
                                  side: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.smallRadius,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onDelete,
                                icon: const Icon(Icons.delete_rounded, size: 18),
                                label: const Text('Delete'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.accentPink,
                                  side: BorderSide(color: AppTheme.accentPink.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.smallRadius,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
