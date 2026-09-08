import 'dart:convert';
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:demandium/feature/lead/repository/lead_repo.dart';
import 'package:demandium/utils/core_export.dart';

final database = AppDatabase();

Future<Map<String, Map<String, String>>> init() async {

  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  /// Repository
  Get.lazyPut(() => DataSyncRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => CategoryRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => WebLandingRepo(apiClient: Get.find(), sharedPreferences:  Get.find()));
  Get.lazyPut(() => AdvertisementRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ServiceRepo(apiClient:Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => CampaignRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ProviderBookingRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthRepo(sharedPreferences:Get.find(),apiClient: Get.find()));
  Get.lazyPut(() => DataSyncRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => UserRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => CouponRepo(apiClient: Get.find()));
  Get.lazyPut(() => CreatePostRepo(apiClient: Get.find()));
  Get.lazyPut(() => CheckoutRepo(apiClient: Get.find()));
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()));
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()));
  Get.lazyPut(() => MyFavoriteRepo(apiClient: Get.find()));
  Get.lazyPut(() => SearchRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient:Get.find() , sharedPreferences: Get.find()));
  Get.lazyPut(() => ServiceBookingRepo(sharedPreferences:Get.find(),apiClient: Get.find()));
  Get.put(BookingDetailsRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => LeadRepo(apiClient: Get.find()));




  /// Controller
  Get.lazyPut(() => LeadController(leadRepo: Get.find()));
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => CategoryController(categoryRepo: Get.find()));
  Get.lazyPut(() => WebLandingController(webLandingRepo: Get.find()));
  Get.lazyPut(() => AdvertisementController(advertisementRepo: Get.find()));
  Get.lazyPut(() => ServiceController(serviceRepo: Get.find()));
  Get.lazyPut(() => CampaignController( campaignRepo: Get.find()));
  Get.lazyPut(() => NearbyProviderController(providerBookingRepo: Get.find()));
  Get.lazyPut(() => ProviderBookingController(providerBookingRepo: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => BottomNavController());
  Get.lazyPut(() => LanguageController());
  Get.lazyPut(() => CouponController(couponRepo: Get.find()));
  Get.lazyPut(() => CreatePostController(createPostRepo: Get.find()));
  Get.lazyPut(() => CheckOutController(checkoutRepo: Get.find()));
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()));
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()));
  Get.lazyPut(() => MyFavoriteController(myFavoriteRepo: Get.find()));
  Get.lazyPut(() => AllSearchController(searchRepo: Get.find()));
  Get.lazyPut(() => NotificationController( notificationRepo: Get.find()));
  Get.lazyPut(() => ServiceBookingController(serviceBookingRepo: Get.find()));
  Get.put(BookingDetailsController(bookingDetailsRepo: Get.find()));









  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => CartController(cartRepo: CartRepo(sharedPreferences:Get.find(),apiClient: Get.find())));




  Get.lazyPut(() => ScheduleController(scheduleRepo: ScheduleRepo(apiClient: Get.find())));
  Get.lazyPut(() => ServiceAreaController(serviceAreaRepo: ServiceAreaRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => ServiceDetailsController(serviceDetailsRepo: ServiceDetailsRepo(apiClient: Get.find())));


  Map<String, Map<String, String>> languages = {};
  List<Future> languageFutures = [];
  for(LanguageModel languageModel in AppConstants.languages) {
    languageFutures.add(rootBundle.loadString('assets/language/${languageModel.languageCode}.json').then((jsonStringValues) {
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      Map<String, String> jsonValue = {};
      mappedJson.forEach((key, value) {
        jsonValue[key] = value.toString();
      });
      languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonValue;
    }));
  }
  await Future.wait(languageFutures);
  return languages;
}