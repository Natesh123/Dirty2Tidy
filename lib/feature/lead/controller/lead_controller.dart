import 'package:demandium/feature/lead/repository/lead_repo.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class LeadController extends GetxController implements GetxService {
  final LeadRepo leadRepo;
  LeadController({required this.leadRepo});
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _currentLeadId;
  String? get currentLeadId => _currentLeadId;

  void resetLeadId() {
    _currentLeadId = null;
    print('Reset currentLeadId to null');
    update();
  }

  Future<void> saveLeadBasicInfo(String name, String phone, String email, {
    String? serviceName, String? scheduleTime, double? totalAmount, int? quantity,
    String? categoryId, String? serviceId, String? variantKey, String? zoneId
  }) async {
    _isLoading = true;
    update();
    print('Sending Lead Basic Info: Name=$name, Phone=$phone, Email=$email');
    Map<String, dynamic> body = {
      'name': name,
      'phone': phone,
      'email': email,
      'lead_type': 'basic_info'
    };
    if (_currentLeadId != null) {
      body['id'] = _currentLeadId;
    }

    if(serviceName != null) body['service_name'] = serviceName;
    if(scheduleTime != null) body['schedule_time'] = scheduleTime;
    if(totalAmount != null) body['total_amount'] = totalAmount;
    if(quantity != null) body['quantity'] = quantity;
    if(categoryId != null) body['category_id'] = categoryId;
    if(serviceId != null) body['service_id'] = serviceId;
    if(variantKey != null) body['variant_key'] = variantKey;
    if(zoneId != null) body['zone_id'] = zoneId;

    Response response = await leadRepo.saveLead(body);
    print('Lead Basic Info Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Lead basic info saved');
      }
      if (response.body != null && response.body['data'] != null && response.body['data']['id'] != null) {
        _currentLeadId = response.body['data']['id'].toString();
        print('Stored current lead ID: $_currentLeadId');
      }
    } else {
      print('Failed to save lead info: ${response.statusText}');
      customSnackBar("Lead Save Failed: ${response.statusCode}", type: ToasterMessageType.error);
    }
    _isLoading = false;
    update();
  }

  Future<void> saveLeadAddress(AddressModel address, {
    String? name, String? phone, String? email, 
    String? serviceName, String? scheduleTime, double? totalAmount, 
    String? bookingType, String? paymentStatus,
    String? readableId, String? categoryId, String? subCategoryId, String? serviceId,
    String? variantKey, int? quantity, double? serviceCost, double? taxAmount,
    double? discountAmount, String? couponCode, bool? isPaid, String? transactionId, String? providerId,
    String? zoneId
  }) async {
    _isLoading = true;
    update();

    // Fallback logic to retrieve name, phone, and email if not explicitly passed
    String? finalName = name ?? address.contactPersonName;
    String? finalPhone = phone ?? address.contactPersonNumber;
    String? finalEmail = email ?? address.email;

    if (finalName == null || finalName.isEmpty || finalPhone == null || finalPhone.isEmpty || finalEmail == null || finalEmail.isEmpty) {
      if (Get.find<UserController>().userInfoModel != null) {
        var user = Get.find<UserController>().userInfoModel!;
        finalName ??= "${user.fName} ${user.lName}".trim();
        finalPhone ??= user.phone;
        finalEmail ??= user.email;
      }
    }

    print('Saving lead address: ${address.address}');
    Map<String, dynamic> body = {
      'address': address.address,
      'lat': address.latitude,
      'lon': address.longitude,
      'lead_type': 'address_info',
    };
    if (_currentLeadId != null) {
      body['id'] = _currentLeadId;
    }
    
    if(finalName != null && finalName.isNotEmpty) body['name'] = finalName;
    if(finalPhone != null && finalPhone.isNotEmpty) body['phone'] = finalPhone;
    if(finalEmail != null && finalEmail.isNotEmpty) body['email'] = finalEmail;

    if(serviceName != null) body['service_name'] = serviceName;
    if(scheduleTime != null) body['schedule_time'] = scheduleTime;
    if(totalAmount != null) body['total_amount'] = totalAmount;
    if(bookingType != null) body['booking_type'] = bookingType;
    if(paymentStatus != null) body['payment_status'] = paymentStatus;
    
    if(readableId != null) body['readable_id'] = readableId;
    if(categoryId != null) body['category_id'] = categoryId;
    if(subCategoryId != null) body['sub_category_id'] = subCategoryId;
    if(serviceId != null) body['service_id'] = serviceId;
    if(variantKey != null) body['variant_key'] = variantKey;
    if(quantity != null) body['quantity'] = quantity;
    if(serviceCost != null) body['service_cost'] = serviceCost;
    if(taxAmount != null) body['tax_amount'] = taxAmount;
    if(zoneId != null) body['zone_id'] = zoneId;
    if(discountAmount != null) body['discount_amount'] = discountAmount;
    if(couponCode != null) body['coupon_code'] = couponCode;
    if(isPaid != null) body['is_paid'] = isPaid ? 1 : 0;
    if(transactionId != null) body['transaction_id'] = transactionId;
    if(providerId != null) body['provider_id'] = providerId;
    
    if(address.zoneId != null) body['zone_id'] = address.zoneId;

    print('Sending Lead Address Info: $body');
    Response response = await leadRepo.saveLead(body);
    print('Lead Address Info Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Lead address info saved');
      }
      if (response.body != null && response.body['data'] != null && response.body['data']['id'] != null) {
        _currentLeadId = response.body['data']['id'].toString();
        print('Stored current lead ID: $_currentLeadId');
      }
    } else {
      print('Failed to save lead address: ${response.statusText}');
      customSnackBar("Address Save Failed: ${response.statusCode}", type: ToasterMessageType.error);
    }
    _isLoading = false;
    update();
  }
}
