import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/models/category_types_model.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  List<Service>? _searchProductList = [];
  List<CategoryModel>? _campaignBasedCategoryList ;

  bool _isLoading = false;
  int? _pageSize;
  bool? _isSearching = false;
  final String _type = 'all';
  final String _searchText = '';

  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get campaignBasedCategoryList => _campaignBasedCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Service>? get searchServiceList => _searchProductList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  bool? get isSearching => _isSearching;
  String? get type => _type;
  String? get searchText => _searchText;


  Future<void> getCategoryList(bool reload ) async {

    if(_categoryList == null || reload){
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> categoryRepo.getCategoryList<CacheResponseData>( source: DataSourceEnum.local),
        fetchFromClient: ()=> categoryRepo.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _categoryList = [];
          if (data != null && data['content'] != null && data['content']['data'] != null) {
            data['content']['data'].forEach((category) {
              try {
                CategoryModel model = CategoryModel.fromJson(category);

                // Robust image path reconstruction
                if(model.image != null && model.image!.isNotEmpty && !model.image!.contains('null')){
                   bool needsReconstruct = false;
                   if(model.imageFullPath == null || model.imageFullPath!.isEmpty || model.imageFullPath!.contains('null') || model.imageFullPath!.contains('localhost')){
                     needsReconstruct = true;
                   } else if (!model.imageFullPath!.startsWith('http')) {
                     needsReconstruct = true;
                   }

                   if(needsReconstruct){
                      if(model.image!.startsWith('http')){
                        model.imageFullPath = model.image;
                      } else {
                        // Cleanup image filename
                        String cleanImage = model.image!;
                        if(cleanImage.contains('public/')){
                          cleanImage = cleanImage.split('public/').last;
                        }
                        if(cleanImage.contains('category/')){
                          cleanImage = cleanImage.split('category/').last;
                        }
                        if(cleanImage.startsWith('/')){
                          cleanImage = cleanImage.substring(1);
                        }
                        
                        // We will provide the most common public facing storage path first
                        // Browsers prefer /storage/ over /storage/app/public/
                        model.imageFullPath = "${AppConstants.baseUrl}/storage/category/$cleanImage";
                        
                        // If there is any concern about symlink, we could also use alternative, 
                        // but /storage/category/ is the standard web-accessible path.
                      }
                   }
                }

                // Final Encode and Route through Server Optimizer for Best Mobile Performance
                if(model.imageFullPath != null && model.imageFullPath!.isNotEmpty && !model.imageFullPath!.contains('null')){
                   String finalPath = model.imageFullPath!.trim();
                   
                   // Extract relative path to pass to optimizer
                   String relativePath = "";
                   if(finalPath.contains('/storage/')){
                     relativePath = "storage/${finalPath.split('/storage/').last}";
                   }
                   
                   if(relativePath.isNotEmpty){
                     // Use the optimizer route we just created in Laravel
                     model.imageFullPath = "${AppConstants.baseUrl}/image/optimize?path=$relativePath";
                   } else {
                     model.imageFullPath = Uri.encodeFull(finalPath);
                   }
                }

                if(model.isActive == true && model.name != null && model.name!.isNotEmpty){
                  _categoryList!.add(model);
                }
              } catch (e) {
                if (kDebugMode) {
                  print("Category Parse Error: $e");
                }
              }
            });
          }
          // Sort categories according to the professional sequence
          if (_categoryList != null && _categoryList!.isNotEmpty) {
            final targetOrder = [
              "end of lease cleaning",
              "oven cleaning",
              "bbq cleaning",
              "carpet steam cleaning",
              "window cleaning",
              "upholstery cleaning",
              "spring cleaning",
              "office cleaning",
              "move in cleaning",
              "domestic cleaning"
            ];
            
            _categoryList!.sort((a, b) {
              String nameA = (a.name ?? "").toLowerCase().trim();
              String nameB = (b.name ?? "").toLowerCase().trim();
              
              int indexA = targetOrder.indexWhere((element) => nameA.contains(element));
              int indexB = targetOrder.indexWhere((element) => nameB.contains(element));
              
              if (indexA != -1 && indexB != -1) {
                return indexA.compareTo(indexB);
              } else if (indexA != -1) {
                return -1;
              } else if (indexB != -1) {
                return 1;
              } else {
                return nameA.compareTo(nameB);
              }
            });
          }

          Get.find<AllSearchController>().insertCategoryCheckedList();
          update();
        },
      );
    }
  }


  Future<void> getSubCategoryList(String categoryID, {bool shouldUpdate = true}) async {
    _subCategoryList = null;
    if(shouldUpdate){
      update();
    }
    Response response = await categoryRepo.getSubCategoryList(categoryID);
    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      _subCategoryList= [];
      response.body['content']['data'].forEach((category) =>
          _subCategoryList!.addIf(CategoryModel.fromJson(category).isActive , CategoryModel.fromJson(category)));
    } else {
      _subCategoryList= [];
    }
    update();
  }

  Future<void> getCampaignBasedCategoryList(String campaignID, bool isWithPagination) async {
    printLog("inside_campaign_based_category !");
    Response response = await categoryRepo.getItemsBasedOnCampaignId(campaignID: campaignID);

    if (response.body['response_code'] == 'default_200') {
      if(!isWithPagination){
        _campaignBasedCategoryList = [];
      }
      response.body['content']['data'].forEach((categoryTypesModel) {
        if(CategoryTypesModel.fromJson(categoryTypesModel).category != null){
          _campaignBasedCategoryList!.add(CategoryTypesModel.fromJson(categoryTypesModel).category!);
        }
      });
      _isLoading = false;
      Get.toNamed(RouteHelper.getCategoryRoute('fromCampaign',campaignID));
    } else {
      if(response.statusCode != 200){
        ApiChecker.checkApi(response);
      }else{
        customSnackBar('campaign_is_not_available_for_this_service'.tr, type: ToasterMessageType.info);
      }
    }
    update();
  }


  void toggleSearch() {
    _isSearching = !_isSearching!;
    _searchProductList = [];
    update();
  }
  void showBottomLoader() {
    _isLoading = true;
    update();
  }

}
