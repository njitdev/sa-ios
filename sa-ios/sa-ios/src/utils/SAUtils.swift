//
//    sa-ios
//    Copyright (C) 2017 {name of author}
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

class SAUtils: NSObject {
    // MARK: UI Utilities
    // Quick alert
    public static func alert(viewController: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handler)
        alert.addAction(action);
        viewController.present(alert, animated: true, completion: nil);
    }

    // MARK: Local Storage
    // Read KV store
    public static func readLocalKVStore(key: String) -> String? {
        if let defaults = UserDefaults(suiteName: SAConfig.appGroupsSuiteName) {
            return defaults.string(forKey: key)
        }
        return nil
    }

    // Write KV store
    public static func writeLocalKVStore(key: String, val: String?) {
        if val == nil { return }
        if let defaults = UserDefaults(suiteName: SAConfig.appGroupsSuiteName) {
            defaults.set(val, forKey: key)
        }
    }

    // MARK: Others
    // Initialize installation_id
    public static func initInstallationID() {
        // Read existing installation_id from local storage
        if let iid: String = SAUtils.readLocalKVStore(key: "installation_id") {
            SAGlobal.installation_id = iid;
        } else {
            // If not exist, generate a new one
            SAGlobal.installation_id = SAUtils.randomString(length: 16);

            // Save
            SAUtils.writeLocalKVStore(key: "installation_id", val: SAGlobal.installation_id)
        }
    }

#if !TARGET_IS_EXTENSION
    // Google Analytics: Send screen view event
    public static func GAISendScreenView(_ screenName: String) {
        // Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        let build = (GAIDictionaryBuilder.createScreenView().build() as Dictionary) as [AnyHashable: Any]
        tracker?.send(build)
    }

    // Open a URL
    public static func openURL(url: String) {
        if let url = URL(string: url) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
#endif

    // Generate random string
    public static func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    // Get day of week
    public static func dayOfWeek() -> Int {
        let todayDate = Date()
        let myCalendar = Calendar(identifier: .gregorian)
        var weekDay = myCalendar.component(.weekday, from: todayDate)
        weekDay -= 1
        if weekDay == 0 { weekDay = 7 }
        return weekDay
    }
}
