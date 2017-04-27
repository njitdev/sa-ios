//
//  UserModels.swift
//  sa-ios
//
//  Created by Yunzhu Li on 4/25/17.
//
//

import UIKit
import Alamofire

class SchoolSystemModels: NSObject {
    // Message Board base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/school/" + SAConfig.schoolIdentifier

    // Submit login info
    // Responds with a session_id
    static func submitAuthInfo(student_login: String, student_password: String, captcha: String?,
                               completionHandler: @escaping (String?, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["student_login": student_login, "student_password": student_password];
        if let v = captcha { params["captcha"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/auth/submit", method: .post, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(_):

                // Extract data
                let r_dict = response.result.value as? [String: Any]
                let r_result = r_dict?["result"] as? [String: Any]
                let r_auth_result = r_result?["auth_result"] as? Bool
                let r_session_id = r_result?["session_id"] as? String

                // Authentication result
                if let success = r_auth_result {
                    if (!success) {
                        completionHandler(nil, "请检查用户名和密码")
                        return
                    }
                }

                // Pass session_id
                completionHandler(r_session_id, "ok");

            default:
                completionHandler(nil, "网络通信错误");
            }
        }
    }
}
