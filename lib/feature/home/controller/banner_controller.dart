import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class BannerController extends GetxController implements GetxService {
  final BannerRepo bannerRepo;
  BannerController({required this.bannerRepo});

  List<BannerModel>? _banners;
  List<BannerModel>? get banners => _banners;

  int? _currentIndex = 0;
  int? get currentIndex => _currentIndex;

  Future<void> getBannerList(bool reload) async {


    if(_banners == null || reload){
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> bannerRepo.getBannerList<CacheResponseData>( source: DataSourceEnum.local),
        fetchFromClient: ()=> bannerRepo.getBannerList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _banners = [];
          print("DEBUG: Banner Response: $data"); // LOG
          data['content']['data'].forEach((banner) {
            _banners!.add(BannerModel.fromJson(banner));
          });
          print("DEBUG: Parsed Banners Count: ${_banners!.length}"); // LOG
          update();
        },
      );
    }

  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }


  Future<void> navigateFromBanner(String resourceType, String bannerID, String link, String resourceID, {String categoryName = ''})async {
    switch (resourceType){
      case 'category':
        Get.toNamed(RouteHelper.allServiceScreenRoute('category_services', categoryId: bannerID));
        break;

      case 'link':
        if (await canLaunchUrl(Uri.parse(link))) {
          await launchUrl(Uri.parse(link));
        } else {
          throw 'Could not launch $link';
        }
        break;
      case 'service':
        Get.toNamed(RouteHelper.getServiceRoute(resourceID));
        break;
      default:
    }
  }
}
