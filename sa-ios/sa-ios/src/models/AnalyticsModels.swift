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
import Alamofire

class AnalyticsModels: NSObject {
    // Analytics base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/app/analytics"

    // Submit new start log
    static func submitStartLog(school: String, installation_id: String, client_version: String, device_info: String, completionHandler: @escaping (Bool, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["school": school, "installation_id": installation_id, "client_version": client_version, "device_info": device_info]

        // Make request
        Alamofire.request(self.apiBaseURL + "/start", method: .post, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completionHandler(true, "ok")
            default:
                completionHandler(false, "error")
            }
        }
    }
}
