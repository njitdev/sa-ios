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

    // Get student basic info
    static func studentBasicInfo(session_id: String, student_id: String?,
                                 completionHandler: @escaping (StudentBasicInfo?, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["session_id": session_id];
        if let v = student_id { params["student_id"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/student/basic-info", parameters: params).responseObject(keyPath: "result") { (response: DataResponse<StudentBasicInfo>) in
            switch response.result {
            case .success(_):
                if let basic_info = response.result.value {
                    completionHandler(basic_info, "ok")
                } else {
                    completionHandler(nil, "数据解析错误")
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

class StudentBasicInfo: Mappable {
    var student_id: String?
    var student_name: String!
    var student_enroll_year: String?
    var student_department: String!
    var student_major: String?
    var student_class: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        student_id          <- map["student_id"]
        student_name        <- map["student_name"]
        student_enroll_year <- map["student_enroll_year"]
        student_department  <- map["student_department"]
        student_major       <- map["student_major"]
        student_class       <- map["student_class"]
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
