import 'package:flutter/material.dart';
import '../models/w3w_models.dart';

class W3WAddressCard extends StatelessWidget {
  final W3WAddress? address;
  final VoidCallback? onCopy;
  final VoidCallback? onNavigate;

  const W3WAddressCard({
    super.key,
    this.address,
    this.onCopy,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address!.words,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: onCopy,
                  tooltip: 'Copy address',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (address!.coordinates != null) ...[
              _buildInfoRow(
                'Coordinates',
                '${address!.coordinates!.lat.toStringAsFixed(6)}, ${address!.coordinates!.lng.toStringAsFixed(6)}',
                Icons.my_location,
              ),
              const SizedBox(height: 8),
            ],
            if (address!.country != null) ...[
              _buildInfoRow('Country', address!.country!, Icons.flag),
              const SizedBox(height: 8),
            ],
            if (address!.nearestPlace != null) ...[
              _buildInfoRow(
                  'Nearest Place', address!.nearestPlace!, Icons.place),
              const SizedBox(height: 8),
            ],
            if (address!.language != null) ...[
              _buildInfoRow('Language', address!.language!, Icons.language),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                if (address!.coordinates != null)
                  ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class W3WErrorWidget extends StatelessWidget {
  final W3WError error;
  final VoidCallback? onRetry;

  const W3WErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.code}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class W3WLoadingWidget extends StatelessWidget {
  final String message;

  const W3WLoadingWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
