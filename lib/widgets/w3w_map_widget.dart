import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/w3w_provider.dart';
import '../models/w3w_models.dart';

class W3WMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final double initialZoom;
  final Function(LatLng)? onMapTap;
  final Function(W3WAddress)? onAddressFound;

  const W3WMapWidget({
    super.key,
    this.initialPosition,
    this.initialZoom = 15.0,
    this.onMapTap,
    this.onAddressFound,
  });

  @override
  State<W3WMapWidget> createState() => _W3WMapWidgetState();
}

class _W3WMapWidgetState extends State<W3WMapWidget> {
  GoogleMapController? _controller;
  Set<Polyline> _gridLines = {};
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<W3WProvider>(
      builder: (context, provider, child) {
        // Update grid lines when grid section changes
        if (provider.gridSection != null) {
          _updateGridLines(provider.gridSection!);
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition ??
                const LatLng(51.5074, -0.1278), // London
            zoom: widget.initialZoom,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          onTap: (LatLng position) {
            _onMapTapped(position, provider);
            widget.onMapTap?.call(position);
          },
          onCameraMove: (CameraPosition position) {
            _onCameraMove(position, provider);
          },
          polylines: _gridLines,
          markers: _markers,
          mapToolbarEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      },
    );
  }

  void _onMapTapped(LatLng position, W3WProvider provider) async {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
        ),
      };
    });

    // Convert coordinates to What3words address
    await provider.convertToWords(
      lat: position.latitude,
      lng: position.longitude,
    );

    if (provider.currentAddress != null && widget.onAddressFound != null) {
      widget.onAddressFound!(provider.currentAddress!);
    }
  }

  void _onCameraMove(CameraPosition position, W3WProvider provider) {
    // Update grid when camera moves (optional - can be expensive)
    // Uncomment if you want real-time grid updates
    /*
    _updateGridForBounds(provider);
    */
  }

  void _updateGridLines(W3WGridSection gridSection) {
    setState(() {
      _gridLines = gridSection.lines.map((line) {
        return Polyline(
          polylineId: PolylineId(
              '${line.start.lat}_${line.start.lng}_${line.end.lat}_${line.end.lng}'),
          points: [
            LatLng(line.start.lat, line.start.lng),
            LatLng(line.end.lat, line.end.lng),
          ],
          color: Colors.red.withOpacity(0.6),
          width: 2,
        );
      }).toSet();
    });
  }

  void _updateGridForBounds(W3WProvider provider) async {
    if (_controller == null) return;

    try {
      final bounds = await _controller!.getVisibleRegion();
      final boundingBox =
          '${bounds.northeast.latitude},${bounds.northeast.longitude},'
          '${bounds.southwest.latitude},${bounds.southwest.longitude}';

      provider.getGridSection(boundingBox: boundingBox);
    } catch (e) {
      // Handle error silently for grid updates
      debugPrint('Error updating grid: $e');
    }
  }

  /// Manually trigger grid update for current visible bounds
  Future<void> updateGrid() async {
    if (_controller != null) {
      final provider = context.read<W3WProvider>();
      _updateGridForBounds(provider);
    }
  }

  /// Center map on coordinates
  Future<void> centerOnCoordinates(double lat, double lng,
      {double zoom = 15.0}) async {
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: zoom),
        ),
      );
    }
  }

  /// Add marker for What3words address
  void addAddressMarker(W3WAddress address) {
    if (address.coordinates != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('w3w_address'),
            position: LatLng(
              address.coordinates!.lat,
              address.coordinates!.lng,
            ),
            infoWindow: InfoWindow(
              title: address.words,
              snippet: address.nearestPlace ?? 'What3words address',
            ),
          ),
        };
      });

      // Center map on the address
      centerOnCoordinates(
        address.coordinates!.lat,
        address.coordinates!.lng,
      );
    }
  }
}
