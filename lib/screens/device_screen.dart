import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // ── Camera ─────────────────────────────────────────────────────────────────
  File? _capturedImage;
  bool _isTakingPhoto = false;

  // ── Geolocation ────────────────────────────────────────────────────────────
  Position? _position;
  String? _address;
  bool _isLoadingLocation = false;
  String? _locationError;

  // ── Accelerometer ──────────────────────────────────────────────────────────
  double _accelX = 0, _accelY = 0, _accelZ = 0;
  StreamSubscription? _accelSub;

  @override
  void initState() {
    super.initState();
    _startAccelerometer();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  // ── Accelerometer logic ────────────────────────────────────────────────────

  void _startAccelerometer() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 200),
    ).listen((event) {
      if (!mounted) return;
      setState(() {
        _accelX = event.x;
        _accelY = event.y;
        _accelZ = event.z;
      });
    });
  }

  // ── Camera logic ──────────────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    setState(() => _isTakingPhoto = true);
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _capturedImage = File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (photo != null && mounted) {
      setState(() => _capturedImage = File(photo.path));
    }
  }

  // ── Geolocation logic ─────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Reverse geocoding
      String? addr;
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          addr = [p.street, p.locality, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {
        // Geocoding may fail — that's ok, we still have coordinates
      }

      if (mounted) {
        setState(() {
          _position = pos;
          _address = addr;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLoadingLocation = false;
        });
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('device_features')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Camera section ──────────────────────────────────────────
          _SectionCard(
            icon: Icons.camera_alt_rounded,
            color: kPrimary,
            title: t.get('camera'),
            child: Column(
              children: [
                if (_capturedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _capturedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.camera_alt,
                        label: t.get('take_photo'),
                        color: kPrimary,
                        isLoading: _isTakingPhoto,
                        onTap: _takePhoto,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.photo_library,
                        label: t.get('gallery'),
                        color: kCyan,
                        onTap: _pickFromGallery,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Geolocation section ─────────────────────────────────────
          _SectionCard(
            icon: Icons.location_on_rounded,
            color: kSuccess,
            title: t.get('geolocation'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_position != null) ...[
                  _InfoRow(
                    label: t.get('latitude'),
                    value: _position!.latitude.toStringAsFixed(6),
                  ),
                  _InfoRow(
                    label: t.get('longitude'),
                    value: _position!.longitude.toStringAsFixed(6),
                  ),
                  _InfoRow(
                    label: t.get('altitude'),
                    value: '${_position!.altitude.toStringAsFixed(1)} m',
                  ),
                  _InfoRow(
                    label: t.get('speed'),
                    value: '${_position!.speed.toStringAsFixed(1)} m/s',
                  ),
                  if (_address != null)
                    _InfoRow(
                      label: t.get('address'),
                      value: _address!,
                    ),
                ] else if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _locationError!,
                      style: const TextStyle(
                        color: kDanger,
                        fontFamily: 'PoppinsRegular',
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      t.get('tap_to_get_location'),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'PoppinsLight',
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.my_location,
                  label: t.get('get_location'),
                  color: kSuccess,
                  isLoading: _isLoadingLocation,
                  onTap: _getLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Accelerometer section ───────────────────────────────────
          _SectionCard(
            icon: Icons.screen_rotation_alt_rounded,
            color: kGold,
            title: t.get('accelerometer'),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AccelValue(axis: 'X', value: _accelX, color: kDanger),
                    _AccelValue(axis: 'Y', value: _accelY, color: kSuccess),
                    _AccelValue(axis: 'Z', value: _accelZ, color: kCyan),
                  ],
                ),
                const SizedBox(height: 16),
                // Visual tilt indicator
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: kGold.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Crosshairs
                      Container(width: 1, height: 180, color: colorScheme.outline),
                      Container(width: 180, height: 1, color: colorScheme.outline),
                      // Tilt dot
                      Transform.translate(
                        offset: Offset(
                          (_accelX * -8).clamp(-80, 80),
                          (_accelY * 8).clamp(-80, 80),
                        ),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGold,
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.get('tilt_device'),
                  style: TextStyle(
                    fontFamily: 'PoppinsLight',
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PoppinsMedium',
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PoppinsRegular',
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccelValue extends StatelessWidget {
  final String axis;
  final double value;
  final Color color;

  const _AccelValue({
    required this.axis,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          axis,
          style: TextStyle(
            fontFamily: 'PoppinsBold',
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontFamily: 'PoppinsMedium',
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          'm/s\u00B2',
          style: TextStyle(
            fontFamily: 'PoppinsLight',
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
