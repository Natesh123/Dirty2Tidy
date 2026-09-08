import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'dart:convert';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class CartRepo extends DataSyncRepo{
  CartRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});

  Future<Response> addToCartListToServer(CartModelBody cartModel) async {
    String zoneId = "";
    if(Get.isRegistered<LocationController>()){
      zoneId = Get.find<LocationController>().getUserAddress()?.zoneId ?? "";
    }else if(sharedPreferences!.containsKey(AppConstants.userAddress)){
      AddressModel address = AddressModel.fromJson(jsonDecode(sharedPreferences!.getString(AppConstants.userAddress)!));
      zoneId = address.zoneId ?? "";
    }
    
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);

    Map<String, dynamic> body = cartModel.toJson();
    body['guest_id'] = guestId;

    return await apiClient.postData(AppConstants.addToCart, body, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'zoneid': zoneId,
      AppConstants.localizationKey: sharedPreferences!.getString(AppConstants.languageCode) ?? AppConstants.languages[0].languageCode!,
      'Authorization': 'Bearer ${apiClient.token}',
      AppConstants.guestId : guestId,
    });
  }

  Future<ApiResponseModel<T>> getCartListFromServer<T>({required DataSourceEnum source}) async {
    String zoneId = "";
    if(Get.isRegistered<LocationController>()){
      zoneId = Get.find<LocationController>().getUserAddress()?.zoneId ?? "";
    }else if(sharedPreferences!.containsKey(AppConstants.userAddress)){
      AddressModel address = AddressModel.fromJson(jsonDecode(sharedPreferences!.getString(AppConstants.userAddress)!));
      zoneId = address.zoneId ?? "";
    }
    
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);

    return await fetchData<T>("${AppConstants.getCartList}&guest_id=$guestId", source, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'zoneid': zoneId,
      AppConstants.localizationKey: sharedPreferences!.getString(AppConstants.languageCode) ?? AppConstants.languages[0].languageCode!,
      'Authorization': 'Bearer ${apiClient.token}',
      AppConstants.guestId : guestId,
    });
  }

  Future<Response> removeCartFromServer(String cartID) async {
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);
    return await apiClient.deleteData("${AppConstants.removeCartItem}$cartID?guest_id=$guestId");
  }

  Future<Response> removeAllCartFromServer() async {
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);
    return await apiClient.deleteData("${AppConstants.removeAllCartItem}?guest_id=$guestId");
  }

  Future<Response> updateCartQuantity(String cartID, int quantity)async{
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);
    return await apiClient.putData("${AppConstants.updateCartQuantity}$cartID?guest_id=$guestId", { 'quantity': quantity});
  }

  Future<Response> updateProvider(String providerId)async{
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);
    return await apiClient.postData(AppConstants.updateCartProvider,
      { 'provider_id': providerId,
        "_method":"put",
        "guest_id": guestId
      });
  }

  Future<Response> getProviderBasedOnSubcategory(String subcategoryId) async {
    return await apiClient.getData("${AppConstants.getProviderBasedOnSubcategory}?sub_category_id=$subcategoryId");
  }

  Future<Response> addRebookToServer(String bookingId) async {
    String guestId = Get.find<SplashController>().getGuestId();
    if(guestId.length > 36) guestId = guestId.substring(0, 36);
    return await apiClient.postData(AppConstants.rebookApi, {'booking_id' : bookingId, 'guest_id' : guestId} );
  }


}