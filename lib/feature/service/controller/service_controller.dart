import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/feature/service/model/recommendation_search_model.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';


class ServiceController extends GetxController implements GetxService {
  final ServiceRepo serviceRepo;
  ServiceController({required this.serviceRepo});


  bool _isLoading = false;
  List<int>? _variationIndex;

  final int _cartIndex = -1;


  ServiceContent? _serviceContent;
  ServiceContent? _offerBasedServiceContent;
  ServiceContent? _popularBasedServiceContent;
  ServiceContent? _recommendedServiceContent;
  ServiceContent? _trendingServiceContent;
  ServiceContent? _recentlyViewServiceContent;

  ServiceContent? _subcategoryBasedServiceContent;
  FeatheredCategoryContent? _featheredCategoryContent;
  Map<String, dynamic>? _promotionalVideo;



  ServiceContent? get serviceContent => _serviceContent;
  ServiceContent? get offerBasedServiceContent => _offerBasedServiceContent;
  ServiceContent? get popularBasedServiceContent => _popularBasedServiceContent;
  ServiceContent? get recommendedBasedServiceContent => _recommendedServiceContent;
  ServiceContent? get trendingServiceContent => _trendingServiceContent;
  ServiceContent? get recentlyViewServiceContent => _recentlyViewServiceContent;
  ServiceContent? get subcategoryBasedServiceContent => _subcategoryBasedServiceContent;
  FeatheredCategoryContent? get featheredCategoryContent => _featheredCategoryContent;
  Map<String, dynamic>? get promotionalVideo => _promotionalVideo;

  List<Service>? _popularServiceList;
  List<Service>? _trendingServiceList;
  List<Service>? _recentlyViewServiceList;
  List<Service>? _recommendedServiceList;
  List<RecommendedSearch>? _recommendedSearchList;
  List<Service>? _subCategoryBasedServiceList;
  List<Service>? _campaignBasedServiceList;
  List<Service>? _offerBasedServiceList;
  List<Service>? _allService;
  List<CategoryData>? _categoryList;


  List<Service>? get allService => _allService ;
  List<Service>? get popularServiceList => _popularServiceList;
  List<Service>? get trendingServiceList => _trendingServiceList;
  List<Service>? get recentlyViewServiceList => _recentlyViewServiceList;
  List<Service>? get recommendedServiceList => _recommendedServiceList;
  List<Service>? get subCategoryBasedServiceList => _subCategoryBasedServiceList;
  List<Service>? get campaignBasedServiceList => _campaignBasedServiceList;
  List<Service>? get offerBasedServiceList => _offerBasedServiceList;
  List<RecommendedSearch>? get recommendedSearchList => _recommendedSearchList;
  List<CategoryData>? get categoryList => _categoryList ;


  bool get isLoading => _isLoading;
  List<int>? get variationIndex => _variationIndex;

  int get cartIndex => _cartIndex;

  String? _fromPage;
  String? get fromPage => _fromPage!;

  final List<double> _lowestPriceList = [];
  List<double> get lowestPriceList => _lowestPriceList;

  @override
  Future<void> onInit() async {
    super.onInit();
    if(Get.find<AuthController>().isLoggedIn()) {
     await Get.find<UserController>().getUserInfo();

     await Get.find<CartController>().getCartListFromServer();
    }
  }



  Future<void> getAllServiceList(int offset, bool reload, {String? categoryId, int limit = 100}) async {
    print("DEBUG_FLUTTER: getAllServiceList called. Offset: $offset, Reload: $reload, CategoryID: $categoryId");

    if(offset != 1 || _allService == null || reload){
      if(reload){
        _allService = null;
      }
      if(offset == 1){
        // DIRECT API CALL to bypass DataSyncHelper caching issues
        ApiResponseModel response = await serviceRepo.getAllServiceList(source: DataSourceEnum.client, categoryId: categoryId, limit: limit);
        if (response.response != null && response.response!.statusCode == 200) {
          _serviceContent = ServiceModel.fromJson(response.response!.body).content;
          _allService = [];
          var list = _serviceContent?.serviceList ?? [];
          sortServiceList(list);
          _allService!.addAll(list);
        } else {
          if(response.response != null) {
            ApiChecker.checkApi(response.response!);
          }
          _allService = [];
        }
        update();
      }else{

        ApiResponseModel response = await serviceRepo.getAllServiceList(offset : offset, source: DataSourceEnum.client, categoryId: categoryId, limit: limit);
        if (response.response != null && response.response!.statusCode == 200) {
          if(reload){
            _allService = [];
          }
          _serviceContent = ServiceModel.fromJson(response.response!.body).content;
          if(_allService != null && offset != 1 ){
            var list = _serviceContent?.serviceList ?? [];
            sortServiceList(list);
            _allService!.addAll(list);
          }

        } else {
          if(response.response != null) {
            ApiChecker.checkApi(response.response!);
          }
        }
        update();
      }
    }
  }


  Future<void> getPopularServiceList(int offset, bool reload) async {

    if(offset != 1 || _popularServiceList == null || reload ){

      if(offset ==1){

        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: ()=> serviceRepo.getPopularServiceList<CacheResponseData>( source: DataSourceEnum.local),
          fetchFromClient: ()=> serviceRepo.getPopularServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _popularBasedServiceContent = ServiceModel.fromJson(data).content;
            _popularServiceList = [];
            _popularServiceList!.addAll(_popularBasedServiceContent!.serviceList!);

            update();
          },
        );

      }else{

        ApiResponseModel response = await serviceRepo.getPopularServiceList(offset: offset, source: DataSourceEnum.client);
        if (response.response != null && response.response!.statusCode == 200) {
          if(reload){
            _popularServiceList = [];
          }
          _popularBasedServiceContent = ServiceModel.fromJson(response.response!.body).content;

          if(_popularServiceList != null && offset != 1){
            _popularServiceList!.addAll(_popularBasedServiceContent?.serviceList ?? []);
          }
        } else {
          if(response.response != null) {
            ApiChecker.checkApi(response.response!);
          }
        }
        update();
      }

    }
  }


  Future<void> getTrendingServiceList(int offset, bool reload) async {
    if(offset != 1 || _trendingServiceList == null || reload ){

      if(offset == 1){

        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: ()=> serviceRepo.getTrendingServiceList<CacheResponseData>( source: DataSourceEnum.local),
          fetchFromClient: ()=> serviceRepo.getTrendingServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _trendingServiceContent = ServiceModel.fromJson(data).content;
            _trendingServiceList = [];
            _trendingServiceList!.addAll(_trendingServiceContent!.serviceList!);

            update();
          },
        );

      }else{
        ApiResponseModel response = await serviceRepo.getTrendingServiceList(offset: offset, source: DataSourceEnum.client);
        if (response.response != null && response.response!.statusCode == 200) {
          if(reload){
            _trendingServiceList = [];
          }
          _trendingServiceContent = ServiceModel.fromJson(response.response!.body).content;
          if(_trendingServiceList != null && offset != 1){
            _trendingServiceList!.addAll(_trendingServiceContent!.serviceList!);
          }
        } else {
           if(response.response != null) {
            ApiChecker.checkApi(response.response!);
          }
        }
        update();
      }

    }
  }



  Future<void> getRecommendedServiceList(int offset, bool reload ) async {
   if(offset != 1 || _recommendedServiceList == null || reload){

     if(offset == 1){
       DataSyncHelper.fetchAndSyncData(
         fetchFromLocal: ()=> serviceRepo.getRecommendedServiceList<CacheResponseData>( source: DataSourceEnum.local),
         fetchFromClient: ()=> serviceRepo.getRecommendedServiceList(source: DataSourceEnum.client),
         onResponse: (data, source) {
           _recommendedServiceContent = ServiceModel.fromJson(data).content;
           _recommendedServiceList = [];
           _recommendedServiceList!.addAll( _recommendedServiceContent!.serviceList!);
           update();
         },
       );
     }else{
       ApiResponseModel response =  await serviceRepo.getRecommendedServiceList(offset: offset, source: DataSourceEnum.client);
       if (response.response != null && response.response!.statusCode == 200) {
         if(reload){
           _recommendedServiceList = [];
         }
         _recommendedServiceContent = ServiceModel.fromJson(response.response!.body).content;
         if(_recommendedServiceList != null && offset != 1){
           _recommendedServiceList!.addAll( _recommendedServiceContent!.serviceList!);
         }
       } else {
         if(response.response != null) {
           ApiChecker.checkApi(response.response!);
         }
       }
       update();
     }
   }
  }


  Future<void> getRecentlyViewedServiceList(int offset, bool reload) async {
    if(offset != 1 || _recentlyViewServiceList == null || reload ){

      if(offset == 1){
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: ()=> serviceRepo.getRecentlyViewedServiceList<CacheResponseData>( source: DataSourceEnum.local),
          fetchFromClient: ()=> serviceRepo.getRecentlyViewedServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _recentlyViewServiceContent = ServiceModel.fromJson(data).content;
            _recentlyViewServiceList = [];
            _recentlyViewServiceList!.addAll(_recentlyViewServiceContent!.serviceList!);
            update();
          },
        );
      }else{
        ApiResponseModel response = await serviceRepo.getRecentlyViewedServiceList(offset: offset, source: DataSourceEnum.client);
        if (response.response != null && response.response!.statusCode == 200) {
          if(reload){
            _recentlyViewServiceList = [];
          }
          _recentlyViewServiceContent = ServiceModel.fromJson(response.response!.body).content;
          if(_recentlyViewServiceList != null && offset != 1){
            _recentlyViewServiceList!.addAll(_recentlyViewServiceContent!.serviceList!);
          }
        }
        update();
      }

    }
  }



  Future<void> getFeatherCategoryList( bool reload) async {

    if(_featheredCategoryContent == null || reload){

      if(reload){
        _categoryList =[];
        _featheredCategoryContent = null;
      }

      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> serviceRepo.getFeatheredCategoryServiceList<CacheResponseData>( source: DataSourceEnum.local),
        fetchFromClient: ()=> serviceRepo.getFeatheredCategoryServiceList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _featheredCategoryContent = FeatheredCategoryModel.fromJson(data).content;

          if(_featheredCategoryContent!.categoryList!=null || _featheredCategoryContent!.categoryList!.isNotEmpty){
            _categoryList =[];
            _featheredCategoryContent?.categoryList?.forEach((element) {
              if(element.servicesByCategory!=null && element.servicesByCategory!.isNotEmpty){
                _categoryList!.add(element);
              }
            });
          }
          update();
        },
      );
    }
  }


  Future<void> getSubCategoryBasedServiceList(String subCategoryID, {bool isShouldUpdate = true, bool showShimmerAlways = false, int offset = 1}) async {
    if(subCategoryID !=""){

      Response response = await serviceRepo.getServiceListBasedOnSubCategory(subCategoryID: subCategoryID,offset: offset);
      if (response.statusCode == 200) {
        _subcategoryBasedServiceContent = ServiceModel.fromJson(response.body).content;
        var list = _subcategoryBasedServiceContent?.serviceList ?? [];
        sortServiceList(list);
        if(offset !=1 && _subCategoryBasedServiceList !=null ){
          _subCategoryBasedServiceList!.addAll(list);
        }else{
          _subCategoryBasedServiceList = [];
          _subCategoryBasedServiceList!.addAll(list);
        }
      } else {
        ApiChecker.checkApi(response);
      }

      if(isShouldUpdate){
        update();
      }

    }else{
      _subCategoryBasedServiceList = [];
    }
  }

  Future<void> getCampaignBasedServiceList(String campaignID, bool reload) async {
    Response response = await serviceRepo.getItemsBasedOnCampaignId(campaignID: campaignID);
    if (response.body['response_code'] == 'default_200') {
      if(reload){
        _campaignBasedServiceList = [];
      }
      response.body['content']['data'].forEach((serviceTypesModel) {
        if(ServiceTypesModel.fromJson(serviceTypesModel).service != null){
          _campaignBasedServiceList!.add(ServiceTypesModel.fromJson(serviceTypesModel).service!);
        }
      });
      Get.toNamed(RouteHelper.allServiceScreenRoute("fromCampaign",campaignID: campaignID));
    } else {
      customSnackBar('campaign_is_not_available_for_this_service'.tr);
      if(response.statusCode != 200){
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> getRecommendedSearchList({bool reload = false}) async {

    if(_recommendedSearchList == null || reload){
      if(reload){
        _recommendedSearchList = null;
        update();
      }
      Response response = await serviceRepo.getRecommendedSearchList();
      if (response.statusCode == 200) {
        if(response.body['content']!=null){
          List<dynamic> list = response.body['content'];
          _recommendedSearchList = [];
          for (var element in list) {
            _recommendedSearchList?.add(RecommendedSearch.fromJson(element));
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }

  }

  int _apiHitCount = 0;

  Future<void> updateIsFavoriteStatus({required String serviceId, required int currentStatus}) async {
    _apiHitCount++;

    Response response = await serviceRepo.updateIsFavoriteStatus(serviceId: serviceId);
    _apiHitCount--;
    int status;
    if(response.statusCode == 200 && (response.body['response_code'] == "service_favorite_store_200" || response.body['response_code'] == "service_remove_favorite_200")){
      if(response.body['content']['status'] !=null){
        status  = response.body['content']['status'];

        customSnackBar(response.body['message'],type: status == 1 ? ToasterMessageType.success : ToasterMessageType.error);
        updateIsFavoriteValue(status, serviceId);
      }
    }
    if(_apiHitCount == 0){
      update();
    }

  }

  updateIsFavoriteValue(int status, String serviceId, {bool shouldUpdate = false}){
    if(_allService !=null){
      int? index = _allService?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _allService![index].isFavorite = status;
      }
    }

    if(_popularServiceList !=null){
      int? index = _popularServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _popularServiceList![index].isFavorite = status;
      }
    }

    if(_trendingServiceList !=null) {
      int? index = _trendingServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _trendingServiceList![index].isFavorite = status;
      }
    }

    if(_recentlyViewServiceList !=null){
      int? index = _recentlyViewServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _recentlyViewServiceList![index].isFavorite = status;
      }
    }

    if(_recommendedServiceList !=null){
      int? index = _recommendedServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _recommendedServiceList![index].isFavorite = status ;
      }
    }

    if(_offerBasedServiceList !=null){
      int? index = _offerBasedServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _offerBasedServiceList![index].isFavorite = status ;
      }
    }

    if(_subCategoryBasedServiceList !=null){
      int? index = _subCategoryBasedServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _subCategoryBasedServiceList![index].isFavorite = status ;
      }
    }

    if(_campaignBasedServiceList !=null){
      int? index = _subCategoryBasedServiceList?.indexWhere((element) => element.id == serviceId);
      if(index !=null && index>-1){
        _subCategoryBasedServiceList![index].isFavorite = status ;
      }
    }

    for(int categoryIndex = 0; categoryIndex < (_categoryList?.length ?? 0) ; categoryIndex ++){
      int? serviceIndex = _categoryList![categoryIndex].servicesByCategory?.indexWhere((element) => element.id ==serviceId);

      if(serviceIndex !=null && serviceIndex>-1){
        _categoryList![categoryIndex].servicesByCategory?[serviceIndex].isFavorite = status;
      }
    }

    Get.find<AllSearchController>().updateIsFavoriteValue(status, serviceId, shouldUpdate: shouldUpdate);
    Get.find<ProviderBookingController>().updateServiceIsFavoriteValue(status, serviceId, shouldUpdate: shouldUpdate);

    if(shouldUpdate){
      update();
    }
  }


   cleanSubCategory(){
    _subCategoryBasedServiceList = null;
    update();
  }


  Future<void> getEmptyCampaignService()async {
    _campaignBasedServiceList = null;
  }

  Future<void> getMixedCampaignList(String campaignID, bool isWithPagination) async {
    if(!isWithPagination){
      _campaignBasedServiceList = [];
    }
    Response response = await serviceRepo.getItemsBasedOnCampaignId(campaignID: campaignID);
    if (response.body['response_code'] == 'default_200') {
      response.body['content']['data'].forEach((serviceTypesModel) {
        if(ServiceTypesModel.fromJson(serviceTypesModel).service != null){
          _campaignBasedServiceList!.add(ServiceTypesModel.fromJson(serviceTypesModel).service!);
        }
      });
      _isLoading = false;
      if(_campaignBasedServiceList!.isEmpty){
        Get.find<CategoryController>().getCampaignBasedCategoryList(campaignID,false);
      }else{
        Get.toNamed(RouteHelper.allServiceScreenRoute("fromCampaign",campaignID: campaignID));
      }
    } else {
      if(response.statusCode != 200){
        ApiChecker.checkApi(response);
      }else{
        customSnackBar('campaign_is_not_available_for_this_service'.tr);
      }
    }
    update();
  }

  Future<void> getOffersList(int offset, bool reload) async {
    Response response = await serviceRepo.getOffersList(offset);
    if (response.statusCode == 200) {
      if( reload){
        _offerBasedServiceList = [];
      }
      _offerBasedServiceContent = ServiceModel.fromJson(response.body).content;
      if(_offerBasedServiceList != null && offset != 1){
        _offerBasedServiceList!.addAll(_offerBasedServiceContent!.serviceList!);
      }else{
        _offerBasedServiceList = [];
        _offerBasedServiceList!.addAll(_offerBasedServiceContent!.serviceList!);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }





  Future<void> getPromotionalVideo(String categoryId) async {
    _promotionalVideo = null;
    print('DEBUG_FLUTTER: Fetching Promotional Video for Category ID: $categoryId');
    print('DEBUG_FLUTTER: Base URL: ${AppConstants.baseUrl}');
    print('DEBUG_FLUTTER: Endpoint: ${AppConstants.promotionalVideoUri}');
    
    Response response = await serviceRepo.getPromotionalVideo(categoryId);
    
    print('DEBUG_FLUTTER: Response Status: ${response.statusCode}');
    print('DEBUG_FLUTTER: Response Body: ${response.body}');

    if (response.statusCode == 200 && response.body is Map && response.body['content'] != null) {
      _promotionalVideo = response.body['content'];
      print('DEBUG_FLUTTER: Video Found: $_promotionalVideo');
    } else {
      print('DEBUG_FLUTTER: No Video Found or Error: ${response.statusCode}');
    }
    update();
  }

  void sortServiceList(List<Service>? list) {
    if (list == null || list.isEmpty) return;
    
    int getServiceSortWeight(String name) {
      String lower = name.toLowerCase().trim();
      if (lower.contains("weber q")) return -1000;
      if (lower == "studio") return -900;
      if (lower.startsWith("studio")) return -890;
      if (lower.contains("single oven")) return 1;
      if (lower.contains("double oven")) return 2;
      if (lower == "once") return 1;
      if (lower == "fortnightly") return 2;
      if (lower == "monthly") return 3;
      if (lower == "quarterly") return 4;
      
      final RegExp seaterRegex = RegExp(r'(\d+)\s*seater');
      final matchSeater = seaterRegex.firstMatch(lower);
      if (matchSeater != null) {
        return 100 + int.parse(matchSeater.group(1)!);
      }
      
      final RegExp burnerRegex = RegExp(r'(\d+)\s*burners');
      final matchBurner = burnerRegex.firstMatch(lower);
      if (matchBurner != null) {
        return 200 + int.parse(matchBurner.group(1)!);
      }
      
      final RegExp bedBathRegex = RegExp(r'(\d+)\s*bedroom\s*(\d+)\s*bathroom');
      final matchBedBath = bedBathRegex.firstMatch(lower);
      if (matchBedBath != null) {
        int bed = int.parse(matchBedBath.group(1)!);
        int bath = int.parse(matchBedBath.group(2)!);
        return 10000 + (bed * 100) + bath;
      }
      
      final RegExp bedRegex = RegExp(r'(\d+)\s*bedroom');
      final matchBed = bedRegex.firstMatch(lower);
      if (matchBed != null) {
        int bed = int.parse(matchBed.group(1)!);
        int modifier = 0;
        if (lower.contains("living") && lower.contains("hallway")) {
          modifier = 2;
        } else if (lower.contains("living")) {
          modifier = 1;
        }
        return 1000 + (bed * 10) + modifier;
      }
      
      if (lower.contains("recleaning")) return 50000;
      if (lower.contains("commercial")) return 50100;
      if (lower.contains("one off")) return 50200;
      
      return 99999;
    }
    
    list.sort((a, b) {
      String nameA = a.name ?? "";
      String nameB = b.name ?? "";
      int weightA = getServiceSortWeight(nameA);
      int weightB = getServiceSortWeight(nameB);
      
      if (weightA != weightB) {
        return weightA.compareTo(weightB);
      }
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });
  }

}
