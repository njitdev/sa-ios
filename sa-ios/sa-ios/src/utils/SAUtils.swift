//
//  SAUtils.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/28/17.
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
