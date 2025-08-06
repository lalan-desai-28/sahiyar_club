// lib/pages/pass_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/pass_list_controller.dart';
import 'package:sahiyar_club/widgets/pass_card.dart';

class PassListPage extends StatelessWidget {
  const PassListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PassListController());

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: c.searchController,
              decoration: InputDecoration(
                labelText: 'Search Passes',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: c.clearSearch,
                ),
              ),
            ),
          ),

          // ————— List area (only this Obx rebuilds) —————
          Expanded(
            child: Obx(() {
              // Loading spinner on initial load
              if (c.isLoading.value && c.passes.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                );
              }

              // Pull-to-refresh + list or empty state
              return RefreshIndicator(
                onRefresh: c.refreshPasses,
                child:
                    c.passes.isEmpty
                        // Empty state when there's no data
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Icon(
                              Icons.badge_outlined,
                              size: 80,
                              color: Colors.amber[300],
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'No Passes Found',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: c.refreshPasses,
                                child: const Text('Refresh'),
                              ),
                            ),
                          ],
                        )
                        // Actual scrollable list + load-more indicator
                        : ListView.builder(
                          controller: c.scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          cacheExtent: 1500,
                          itemExtent: 138,
                          itemCount:
                              c.passes.length + (c.hasMoreData.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < c.passes.length) {
                              return PassCard(fullPass: c.passes[index]);
                            }
                            // Load-more spinner at the bottom
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child:
                                    c.isLoadingMore.value
                                        ? const CircularProgressIndicator(
                                          color: Colors.amber,
                                        )
                                        : const SizedBox.shrink(),
                              ),
                            );
                          },
                        ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
