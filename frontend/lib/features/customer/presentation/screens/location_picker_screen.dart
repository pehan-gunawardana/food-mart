import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const LocationPickerScreen({
    super.key,
    this.initialPosition,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Default to Tangalle, Sri Lanka
  static const LatLng _defaultLocation = LatLng(6.0245, 80.7941);

  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  bool _isResolvingAddress = false;
  String _addressPreview = 'Pan map to choose location';
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ?? _defaultLocation;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Location services are disabled. Please enable GPS.');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            SnackBarUtils.showError(context, 'Location permissions are denied.');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackBarUtils.showError(
            context,
            'Location permissions are permanently denied. Please enable them in system settings.',
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      _currentCenter = newLatLng;

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 16.5),
        );
      }

      _fetchAddressPreview(newLatLng);
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Unable to get current location: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  Future<void> _fetchAddressPreview(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final formatted = _formatPlacemark(place);
        setState(() {
          _addressPreview = formatted.isNotEmpty
              ? formatted
              : '${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (_) {
      // In case of network/geocoding error during preview, display coordinates
      if (mounted) {
        setState(() {
          _addressPreview =
              '${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  String _formatPlacemark(Placemark place) {
    List<String> parts = [];
    if (place.street != null && place.street!.trim().isNotEmpty && place.street != '+') {
      parts.add(place.street!.trim());
    }
    if (place.subLocality != null &&
        place.subLocality!.trim().isNotEmpty &&
        !parts.contains(place.subLocality!.trim())) {
      parts.add(place.subLocality!.trim());
    }
    if (place.locality != null &&
        place.locality!.trim().isNotEmpty &&
        !parts.contains(place.locality!.trim())) {
      parts.add(place.locality!.trim());
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.trim().isNotEmpty &&
        !parts.contains(place.administrativeArea!.trim())) {
      parts.add(place.administrativeArea!.trim());
    }
    return parts.join(', ');
  }

  Future<void> _confirmLocation() async {
    setState(() {
      _isResolvingAddress = true;
    });

    String resolvedAddress = '';

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentCenter.latitude,
        _currentCenter.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        resolvedAddress = _formatPlacemark(place);
      }
    } catch (_) {
      // Fallback in case of geocoding failure
    }

    if (resolvedAddress.trim().isEmpty) {
      resolvedAddress =
          'Lat: ${_currentCenter.latitude.toStringAsFixed(5)}, Lng: ${_currentCenter.longitude.toStringAsFixed(5)}';
    }

    if (mounted) {
      setState(() {
        _isResolvingAddress = false;
      });
      Navigator.of(context).pop(resolvedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-Screen Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15.5,
            ),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _fetchAddressPreview(_currentCenter);
            },
            onCameraMove: (position) {
              _currentCenter = position.target;
            },
            onCameraIdle: () {
              _fetchAddressPreview(_currentCenter);
            },
          ),

          // 2. Static Center Pin (tip points at the exact center of screen)
          Center(
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_pin,
                      size: 48.sp,
                      color: AppTheme.primary,
                    ),
                  ),
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Top Floating App Bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: AppTheme.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Set Delivery Location',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating "My Location" Button
          Positioned(
            right: 16.w,
            bottom: 210.h,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.secondary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              onPressed: _isLoadingCurrentLocation ? null : _moveToCurrentLocation,
              child: _isLoadingCurrentLocation
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primary,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // 5. Bottom Card with Confirm Location Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.primary,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _addressPreview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isResolvingAddress ? null : _confirmLocation,
                      child: _isResolvingAddress
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white),
                                SizedBox(width: 8.w),
                                Text(
                                  'Confirm Location',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
