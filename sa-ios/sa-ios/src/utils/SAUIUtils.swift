//
//  SAUIUtils.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/28/17.
//

import UIKit

class SAUIUtils: NSObject {
    // Quick alert
    public static func alert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action);
        viewController.present(alert, animated: true, completion: nil);
    }
}
