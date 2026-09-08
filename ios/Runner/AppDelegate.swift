import UIKit
import Flutter
import GoogleMaps
import Firebase
import flutter_downloader
import FBSDKCoreKit
import FBSDKLoginKit


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     FirebaseApp.configure()
     GMSServices.provideAPIKey("AIzaSyCKr8UmGNIB9cDKFO2g4qVyaJ8A_C6GATs")
     GeneratedPluginRegistrant.register(with: self)
     FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
