import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class LeadRepo {
  final ApiClient apiClient;
  LeadRepo({required this.apiClient});

  Future<Response> saveLead(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.addLead, body);
  }
}
