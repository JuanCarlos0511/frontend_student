// Bus Map Screen — full-screen map with collaborative bus tracking.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/bus/logic/bus_provider.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> with TickerProviderStateMixin {
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusProvider>().init();
    });
    _startLocationTracking();
  }

  void _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final locSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locSettings).listen((Position? position) {
      if (position != null && mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa los servicios de ubicación.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación denegado.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de ubicación denegado permanentemente.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _reportBus() async {
    LatLng reportLocation;

    final position = await _getCurrentPosition();
    if (position == null || !mounted) return;
    reportLocation = LatLng(position.latitude, position.longitude);

// Find closest bus stop
    BusStop? closestStop;
    double minDistance = double.infinity;

    for (final stop in _busStops) {
      final distance = const Distance().as(LengthUnit.Meter, reportLocation, stop.location);
      if (distance < minDistance) {
        minDistance = distance;
        closestStop = stop;
      }
    }

    if (minDistance > 10.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes estar dentro del radio de 10 metros de una parada.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }

    if (closestStop != null) {
      reportLocation = closestStop.location;
      setState(() {
        for (var s in _busStops) {
          s.isActive = false;
        }
        closestStop!.isActive = true;
        closestStop.lastActive = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se activó la parada: ${closestStop.name}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }

    final success = await context.read<BusProvider>().reportBus(
          reportLocation.latitude,
          reportLocation.longitude,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? '¡Bus reportado exitosamente!' : 'Error al reportar.'),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
      ),
    );
  }

  Future<void> _cancelReport() async {
    if (!mounted) return;
    final success = await context.read<BusProvider>().cancelReport();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Reporte cancelado.'
            : 'No tienes un reporte activo.'),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            // ── Map ──
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 16.0,
                
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.unisocial.student',
                ),

                // Perimeter circles (10m)
                CircleLayer(
                  circles: _busStops.map((stop) {
                    return CircleMarker(
                      point: stop.location,
                      color: AppTheme.primaryRed.withAlpha(40),
                      borderColor: AppTheme.primaryRed,
                      borderStrokeWidth: 2,
                      radius: 10,
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),

                // Static Bus Stops
                MarkerLayer(
                  markers: _busStops.map((stop) {
                    return Marker(
                      point: stop.location,
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          if (stop.isActive && stop.lastActive != null) {
                            final diff = DateTime.now().difference(stop.lastActive!);
                            final msg = diff.inMinutes > 0 
                                ? "Hace ${diff.inMinutes} min" 
                                : "Hace unos segundos";
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(stop.name),
                                content: Text("Activo: $msg"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cerrar"),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.directions_bus,
                          size: stop.isActive ? 40 : 30,
                          color: stop.isActive ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // ── Mock User Location (Testing) ──
                if (_mockUserLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _mockUserLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: AppTheme.primaryRed,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                // ── User marker ──
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                // ── Bus markers ──
                MarkerLayer(
                  markers: provider.reports.map((report) {
                    return Marker(
                      point: LatLng(report.latitude, report.longitude),
                      width: 50,
                      height: 50,
                      child: _BusMarker(report: report),
                    );
                  }).toList(),
                ),
              ],
            ),

            // ── Bottom action buttons ──
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Row(
                children: [
                  // Botón A: "Llegó el bus"
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isReporting || provider.hasActiveReport
                          ? null
                          : _reportBus,
                      icon: provider.isReporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.white))
                          : const Icon(Icons.directions_bus_rounded),
                      label: Text(provider.hasActiveReport
                          ? 'Ya reportaste'
                          : 'Llegó el bus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón B: "No está el bus"
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isReporting || !provider.hasActiveReport
                          ? null
                          : _cancelReport,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('No está el bus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.mediumGrey,
                        backgroundColor: AppTheme.white.withAlpha(230),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Report count badge ──
            Positioned(
              top: 16,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bus_rounded,
                        size: 18, color: AppTheme.primaryRed),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.reports.length} activo${provider.reports.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated bus marker widget with fade-in effect.
class _BusMarker extends StatefulWidget {
  final BusReport report;

  const _BusMarker({required this.report});

  @override
  State<_BusMarker> createState() => _BusMarkerState();
}

class _BusMarkerState extends State<_BusMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Tooltip(
        message:
            '${widget.report.reporterName}\n${widget.report.remainingSeconds ~/ 60} min restantes',
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRed.withAlpha(80),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.directions_bus_rounded,
              color: AppTheme.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}


class BusStop {
  final String name;
  final LatLng location;
  bool isActive;
  DateTime? lastActive;

  BusStop({
    required this.name,
    required this.location,
    this.isActive = false,
    this.lastActive,
  });
}