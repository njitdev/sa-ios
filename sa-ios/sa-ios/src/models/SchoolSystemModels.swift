//
//  UserModels.swift
//  sa-ios
//
//  Created by Yunzhu Li on 4/25/17.
//
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

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
        Alamofire.request(self.apiBaseURL + "/auth/submit", method: .post, parameters: params).responseObject { (response: DataResponse<AuthSubmitResponse>) in
            switch response.result {
            case .success(_):
                let resp_obj = response.result.value
                if resp_obj?.auth_result == true {
                    completionHandler(resp_obj!.session_id!, "ok")
                } else {
                    completionHandler(nil, "请检查用户名和密码")
                }
            default:
                completionHandler(nil, "网络通信错误");
            }
        }
    }

    // Get grades
    static func grades(session_id: String, student_id: String?,
                       completionHandler: @escaping ([GradeItem]?, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["session_id": session_id];
        if let v = student_id { params["student_id"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/grades", parameters: params).responseArray(keyPath: "result") { (response: DataResponse<[GradeItem]>) in
            switch response.result {
            case .success(_):
                if let grades = response.result.value {
                    completionHandler(grades, "ok")
                } else {
                    completionHandler(nil, "数据解析错误")
                }
            default:
                completionHandler(nil, "网络通信错误");
            }
        }
    }
}

class AuthSubmitResponse: Mappable {
    var auth_result: Bool!
    var session_id: String?
    var message: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        auth_result <- map["result.auth_result"]
        session_id  <- map["result.session_id"]
        message     <- map["message"]
    }
}

class GradeItem: Mappable {
    var course_id: String?
    var course_name: String!
    var course_category: String?
    var course_isrequired: String?
    var course_hours: String?
    var term: String?
    var credits: String!
    var score: String!
    var grade_point: String?
    var exam_type: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        course_id         <- map["course_id"]
        course_name       <- map["course_name"]
        course_category   <- map["course_category"]
        course_isrequired <- map["course_isrequired"]
        course_hours      <- map["course_hours"]
        term              <- map["term"]
        credits           <- map["credits"]
        score             <- map["score"]
        grade_point       <- map["grade_point"]
        exam_type         <- map["exam_type"]
    }
}
