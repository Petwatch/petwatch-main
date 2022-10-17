// import UIKit
// import FacebookCore
// import FBSDKCoreKit

// @UIApplicationMain
// class AppDelegate: UIResponder, UIApplicationDelegate {    
//     func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {          
//         ApplicationDelegate.shared.application(
//             application,
//             didFinishLaunchingWithOptions: launchOptions
//         )
//        return true
//     }
          
//     func application(
//         _ app: UIApplication,
//         open url: URL,
//         options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//     ) -> Bool {
//         ApplicationDelegate.shared.application(
//             app,
//             open: url,
//             sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//             annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//         )
//     }  
// }

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}