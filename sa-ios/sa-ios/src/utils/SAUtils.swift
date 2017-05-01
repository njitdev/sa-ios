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
    public static func alert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action);
        viewController.present(alert, animated: true, completion: nil);
    }

    // MARK: Local Storage
    // Read KV store
    public static func readLocalKVStore(key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key)
    }

    // Write KV store
    public static func writeLocalKVStore(key: String, val: String?) {
        if val == nil { return }
        let defaults = UserDefaults.standard
        defaults.set(val, forKey: key)
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
}
