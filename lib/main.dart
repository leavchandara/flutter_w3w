import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w3w/config/constant.dart';

import 'providers/w3w_provider.dart';
import 'models/w3w_models.dart';
import 'widgets/w3w_auto_suggest_field.dart';
import 'widgets/w3w_address_card.dart';
import 'widgets/w3w_map_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => W3WProvider(
        // Replace with your actual What3words API key
        apiKey: Constant.apiKeyW3w
      ),
      child: MaterialApp(
        title: 'What3words Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const W3WHomePage(),
      ),
    );
  }
}

class W3WHomePage extends StatefulWidget {
  const W3WHomePage({super.key});

  @override
  State<W3WHomePage> createState() => _W3WHomePageState();
}

class _W3WHomePageState extends State<W3WHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('What3words Demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'AutoSuggest'),
            Tab(icon: Icon(Icons.location_on), text: 'Convert'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.grid_on), text: 'Grid'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAutoSuggestTab(),
          _buildConvertTab(),
          _buildMapTab(),
          _buildGridTab(),
        ],
      ),
    );
  }

  Widget _buildAutoSuggestTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AutoSuggest',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start typing to get What3words suggestions. This helps reduce input errors.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          W3WAutoSuggestField(
            focus: _currentPosition != null
                ? W3WCoordinates(
                    lat: _currentPosition!.latitude,
                    lng: _currentPosition!.longitude,
                  )
                : null,
            onSuggestionSelected: (suggestion) async {
              // Convert suggestion to coordinates
              await context.read<W3WProvider>().convertToCoordinates(
                    words: suggestion.words,
                  );
            },
          ),
          const SizedBox(height: 16),
          Consumer<W3WProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return W3WErrorWidget(
                  error: provider.error!,
                  onRetry: () => provider.clearError(),
                );
              }

              if (provider.currentAddress != null) {
                return W3WAddressCard(
                  address: provider.currentAddress,
                  onCopy: () =>
                      _copyToClipboard(provider.currentAddress!.words),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConvertTab() {
    final TextEditingController wordsController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Convert Coordinates & Addresses',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Convert coordinates to words
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coordinates → What3words',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final lat = double.tryParse(latController.text);
                        final lng = double.tryParse(lngController.text);
                        if (lat != null && lng != null) {
                          await context.read<W3WProvider>().convertToWords(
                                lat: lat,
                                lng: lng,
                              );
                        }
                      },
                      child: const Text('Convert to Words'),
                    ),
                  ),
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        latController.text =
                            _currentPosition!.latitude.toString();
                        lngController.text =
                            _currentPosition!.longitude.toString();
                      },
                      child: const Text('Use Current Location'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Convert words to coordinates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What3words → Coordinates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: wordsController,
                    decoration: const InputDecoration(
                      labelText: 'What3words address (e.g., index.home.raft)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (wordsController.text.isNotEmpty) {
                          await context
                              .read<W3WProvider>()
                              .convertToCoordinates(
                                words: wordsController.text,
                              );
                        }
                      },
                      child: const Text('Convert to Coordinates'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Consumer<W3WProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const W3WLoadingWidget(message: 'Converting...');
              }

              if (provider.error != null) {
                return W3WErrorWidget(
                  error: provider.error!,
                  onRetry: () => provider.clearError(),
                );
              }

              if (provider.currentAddress != null) {
                return W3WAddressCard(
                  address: provider.currentAddress,
                  onCopy: () =>
                      _copyToClipboard(provider.currentAddress!.words),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Consumer<W3WProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            W3WMapWidget(
              initialPosition: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : null,
              onAddressFound: (address) {
                // Address found callback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Found: ${address.words}'),
                    action: SnackBarAction(
                      label: 'Copy',
                      onPressed: () => _copyToClipboard(address.words),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Tap on the map to get What3words address',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (provider.currentAddress != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: W3WAddressCard(
                  address: provider.currentAddress,
                  onCopy: () =>
                      _copyToClipboard(provider.currentAddress!.words),
                ),
              ),
            if (provider.error != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: W3WErrorWidget(
                  error: provider.error!,
                  onRetry: () => provider.clearError(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGridTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grid Section',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter coordinates to get the What3words grid for that area.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Example: Get grid for London area
                    const boundingBox = '51.521,-0.343,51.512,-0.334';
                    await context.read<W3WProvider>().getGridSection(
                          boundingBox: boundingBox,
                        );
                  },
                  child: const Text('Load London Grid'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentPosition != null
                      ? () async {
                          // Get grid for current location
                          final lat = _currentPosition!.latitude;
                          final lng = _currentPosition!.longitude;
                          const offset = 0.005; // ~500m
                          final boundingBox = '${lat + offset},${lng + offset},'
                              '${lat - offset},${lng - offset}';
                          await context.read<W3WProvider>().getGridSection(
                                boundingBox: boundingBox,
                              );
                        }
                      : null,
                  child: const Text('Load Current Grid'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<W3WProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const W3WLoadingWidget(message: 'Loading grid...');
              }

              if (provider.error != null) {
                return W3WErrorWidget(
                  error: provider.error!,
                  onRetry: () => provider.clearError(),
                );
              }

              if (provider.gridSection != null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grid Section Loaded',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Lines: ${provider.gridSection!.lines.length}'),
                        Text('Northeast: ${provider.gridSection!.northeast}'),
                        Text('Southwest: ${provider.gridSection!.southwest}'),
                        const SizedBox(height: 12),
                        const Text(
                          'Switch to the Map tab to see the grid overlay.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                      'No grid data loaded. Tap a button above to load grid data.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: $text')),
    );
  }
}
