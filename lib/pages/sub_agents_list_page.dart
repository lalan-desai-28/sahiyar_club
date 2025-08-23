import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/controllers/sub_agents_list_controller.dart';

class SubAgentsListPage extends StatefulWidget {
  const SubAgentsListPage({super.key});

  @override
  State<SubAgentsListPage> createState() => _SubAgentsListPageState();
}

class _SubAgentsListPageState extends State<SubAgentsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch sub agents after the first frame is rendered
      Get.find<SubAgentsListController>().fetchSubAgents();
    });
  }

  final SubAgentsListController controller =
      Get.find<SubAgentsListController>();

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        final subAgent = controller.subAgents[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text(subAgent.fullName ?? '---'),
            leading: CircleAvatar(
              child: Text(subAgent.fullName?.substring(0, 1) ?? 'N/A'),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.numbers, size: 16),
                    SizedBox(width: 5),
                    Text(subAgent.agentCode ?? 'No Agent Code'),
                    Text(
                      subAgent.isActive == true ? ' (Active)' : ' (Inactive)',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16),
                    SizedBox(width: 5),
                    Text(subAgent.mobile ?? 'No Mobile'),
                  ],
                ),
              ],
            ),

            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Get.toNamed(
                  AppRoutes.SUB_AGENT_DETAIL_PAGE,
                  arguments: subAgent,
                );
              },
            ),
            onTap: () {
              Get.toNamed(AppRoutes.SUB_AGENT_DETAIL_PAGE, arguments: subAgent);
            },
          ),
        );
      },
      itemCount: controller.subAgents.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.SUB_AGENT_FORM_PAGE);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('Sub Agents')),
      body: Obx(() => _buildBody()),
    );
  }
}
