import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/pass_list_controller.dart';
import 'package:sahiyar_club/widgets/pass_card.dart';

class PassListPage extends StatefulWidget {
  const PassListPage({super.key});

  @override
  State<PassListPage> createState() => _PassListPageState();
}

class _PassListPageState extends State<PassListPage> {
  final PassListController _controller = PassListController();

  @override
  void initState() {
    super.initState();
    _controller.fetchMyPasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() => _buildBody()));
  }

  Widget _buildBody() {
    if (_controller.isLoading.value) return _buildLoadingState();
    if (_controller.passes.isEmpty) return _buildEmptyState();
    return _buildPassList();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.amber));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge_outlined, size: 80, color: Colors.amber[300]),
          const SizedBox(height: 16),
          const Text('No Passes Found', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.fetchMyPasses,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassList() {
    return RefreshIndicator(
      onRefresh: _controller.refreshPasses,
      child: ListView.builder(
        controller: _controller.scrollController,
        itemCount:
            _controller.passes.length + (_controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _controller.passes.length) {
            return PassCard(fullPass: _controller.passes[index]);
          }
          return _buildLoadMoreIndicator();
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!_controller.isLoadingMore.value) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
  }
}
