//
//  SAConfig.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/21/17.
//

import UIKit

class SAConfig: NSObject {
    public static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    public static let APIBaseURL = "https://sa-api-dev.njitdev.com"

    // 3rd party libraries
    public static let sentryClientKey = "https://63cb6cff1db447298fc2960f52382072:34fa1440cdda48009ae3cddf66d96127@sentry.io/154188"
    public static let GAPropertyID = "UA-61812304-1"

}
