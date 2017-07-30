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

class SAConfig: NSObject {
    public static let appName = "MyGDUT"

#if DEBUG
    public static let APIBaseURL = "https://sa-api-dev.njitdev.com"
//    public static let APIBaseURL = "http://127.0.0.1:8000"
#else
    public static let APIBaseURL = "https://sa-api-prd.njitdev.com"
#endif

    public static let schoolIdentifier = "gdut"
    public static let appGroupsSuiteName = "group.com.njitdev.sa-ios." + SAConfig.schoolIdentifier

    // 3rd party libraries
    public static let GAPropertyID = "UA-61812304-1"
    public static let oneSignalAppID = "b09405cc-9473-4a3c-90ee-bd8300debb50"
    public static let rollbarClientToken = "b321f22cfeaa4ea4b4b22c1f2d0222e2"
}
