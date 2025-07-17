import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/connectivity_controller.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectivityController connectivityController = Get.find();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.error.withOpacity(0.6),
              ),
              const SizedBox(height: 32),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your internet connection and try again.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      connectivityController.isConnected.value
                          ? null
                          : () {
                            connectivityController.onInit();
                          },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        connectivityController.isConnected.value
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          connectivityController.isConnected.value
                              ? Colors.green
                              : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        connectivityController.isConnected.value
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        size: 16,
                        color:
                            connectivityController.isConnected.value
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        connectivityController.isConnected.value
                            ? 'Connected (${connectivityController.connectionStatus.value.name})'
                            : 'Disconnected',
                        style: TextStyle(
                          color:
                              connectivityController.isConnected.value
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
