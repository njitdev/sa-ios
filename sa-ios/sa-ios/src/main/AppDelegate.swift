//
//    sa-ios
//    Copyright (C) 2017 Yunzhu Li
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import AlamofireNetworkActivityIndicator
import OneSignal
import Rollbar

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Google Analytics
        GAI.sharedInstance().tracker(withTrackingId: SAConfig.GAPropertyID)

        // Configure GAI
        if let gai = GAI.sharedInstance() {
            gai.dispatchInterval = 10; // Send events every 10 seconds
            gai.trackUncaughtExceptions = true  // Report uncaught exceptions
            // gai.logger.logLevel = GAILogLevel.verbose  // Remove before app release
        } else {
            assert(false, "Google Analytics not configured correctly")
        }

        // Configure rollbar
        let rollbarConfig: RollbarConfiguration = RollbarConfiguration()
#if DEBUG
        rollbarConfig.environment = "development"
#else
        rollbarConfig.environment = "production"
#endif
        Rollbar.initWithAccessToken(SAConfig.rollbarClientToken, configuration: rollbarConfig)

        // Enable automatic NetworkActivityIndicator management
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.1

        // Installation ID
        SAUtils.initInstallationID()

        // Submit start log
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            AnalyticsModels.submitStartLog(school: SAConfig.schoolIdentifier,
                                           installation_id: SAGlobal.installation_id,
                                           client_version: version,
                                           device_info: UIDevice.current.name,
                                           completionHandler: { (_, _) in })
        }

        // Push notifications
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: SAConfig.oneSignalAppID,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
