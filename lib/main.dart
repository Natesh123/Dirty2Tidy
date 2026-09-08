import 'dart:io' as io;
import 'package:get/get.dart';
import 'utils/core_export.dart';
import 'helper/get_di.dart' as di;
import 'package:upgrader/upgrader.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
    await FlutterDownloader.initialize(
    );
  }
  setPathUrlStrategy();
  if(GetPlatform.isWeb){
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyCodd-QN4TJGNJx4EDBFITzQSzpabPY8JA",
              authDomain: "dirt2tidy-55848.firebaseapp.com",
              projectId: "dirt2tidy-55848",
              storageBucket: "dirt2tidy-55848.firebasestorage.app",
              messagingSenderId: "185184234632",
              appId: "1:185184234632:web:83be7ebd4116fb7dc1c33d"
          )
      );
    } catch (e) {
      if (kDebugMode) {
        print("Firebase Web Init Error: $e");
      }
    }
    try {
      FacebookAuth.instance.webAndDesktopInitialize(
        appId: "637072917840079",
        cookie: true,
        xfbml: true,
        version: "v15.0",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Facebook Web Init Error: $e");
      }
    }
  }else{
    await Firebase.initializeApp();
  }

  if(defaultTargetPlatform == TargetPlatform.android) {
    await FirebaseMessaging.instance.requestPermission();
  }




  Map<String, Map<String, String>> languages = await di.init();
  NotificationBody? body;
  String? path;
  try {
    if (!kIsWeb) {
      path =  await initDynamicLinks();
    }

    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }catch(e) {
    if (kDebugMode) {
      print("");
    }
  }
  runApp(MyApp(languages: languages, body: body, route: path,));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;
  final String? route;
  const MyApp({super.key, @required this.languages, @required this.body, this.route});


  @override
  State<MyApp> createState() => _MyAppState();

}



Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  String? path;
  if (uri != null) {
    path = uri.path;
  }else{
    path = null;
  }
  return path;

}

class _MyAppState extends State<MyApp> {
  void _route() async {

    Get.find<SplashController>().getConfigData().then((success) async {

      if(Get.find<LocationController>().getUserAddress() != null){
        AddressModel addressModel = Get.find<LocationController>().getUserAddress()!;
        ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(addressModel.latitude.toString(), addressModel.longitude.toString(), false);
        addressModel.availableServiceCountInZone = responseModel.totalServiceCount;
        Get.find<LocationController>().saveUserAddress(addressModel);
      }
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
      }

    });

  }
  @override
  void initState() {
    super.initState();

    if(kIsWeb || widget.route != null)  {
      Get.find<SplashController>().initSharedData();
      Get.find<SplashController>().getCookiesData();
      Get.find<CartController>().getCartListFromServer();

      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<UserController>().getUserInfo();
      }

      if( Get.find<SplashController>().getGuestId().isEmpty){
        var uuid = const Uuid().v1();
        Get.find<SplashController>().setGuestId(uuid);
      }
      _route();
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? dark : light,
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body, widget.route),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (context, widget) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
              child: Material(
                child: SafeArea(
                  top: false,
                  bottom: GetPlatform.isAndroid,
                  child: UpgradeAlert(
                    showIgnore: false,
                    showLater: false,
                    upgrader: Upgrader(),
                    child: Stack(children: [
                      widget!,
  
                      GetBuilder<SplashController>(builder: (splashController){
                        if(!splashController.savedCookiesData || !splashController.getAcceptCookiesStatus(splashController.configModel.content?.cookiesText??"")){
                          return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter,child: CookiesView()) :const SizedBox();
                        }else{
                          return const SizedBox();
                        }
                      })
                    ],),
                  ),
                ),
              ),
            ),
          );
        });
      });
    });
  }
}
class MyHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (io.X509Certificate cert, String host, int port) => true;
  }
}