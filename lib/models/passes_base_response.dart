import 'package:sahiyar_club/models/pass_full.dart';

class PassesBaseResponse {
  final List<FullPass>? passes;
  final int page;
  final int limit;
  final int totalPages;
  final int totalCount;

  PassesBaseResponse({
    this.passes,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalCount,
  });

  factory PassesBaseResponse.fromJson(Map<String, dynamic> json) {
    return PassesBaseResponse(
      passes:
          (json['passes'] as List<dynamic>?)
              ?.map((item) => FullPass.fromJson(item))
              .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
