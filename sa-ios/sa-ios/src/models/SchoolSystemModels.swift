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
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class SchoolSystemModels: NSObject {
    // School system base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/school/" + SAConfig.schoolIdentifier

    // Initialize authentication
    static func initAuth(completionHandler: @escaping (Bool?, String?, String) -> Void) {
        // Make request
        Alamofire.request(self.apiBaseURL + "/auth/init", method: .get).responseObject { (response: DataResponse<AuthInitResponse>) in
            switch response.result {
            case .success:
                if let resp_obj = response.result.value {
                    completionHandler(resp_obj.captcha_enabled, resp_obj.session_id, resp_obj.message)
                }
            default:
                completionHandler(nil, nil, "教务系统太烂无法通信，请稍后再试")
            }
        }
    }

    // Download captcha and return a UIImage
    static func fetchCaptcha(session_id: String, completionHandler: @escaping (UIImage?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["session_id": session_id];

        // Make request
        Alamofire.request(self.apiBaseURL + "/auth/captcha", parameters: params).response { response in
            if let data = response.data {
                if let img = UIImage(data: data) {
                    completionHandler(img, "ok")
                } else {
                    completionHandler(nil, "验证码获取失败，请重试")
                }
            } else {
                completionHandler(nil, "验证码获取失败，请重试")
            }
        }
    }

    // Submit login info
    // Responds with a session_id
    static func submitAuthInfo(installation_id: String, session_id: String?, student_login: String, student_password: String, captcha: String?,
                               completionHandler: @escaping (Bool, String?, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["installation_id": installation_id, "student_login": student_login, "student_password": student_password]
        if let v = session_id { params["session_id"] = v }
        if let v = captcha { params["captcha"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/auth/submit", method: .post, parameters: params).validate(statusCode: 200..<300).responseObject { (response: DataResponse<AuthSubmitResponse>) in
            switch response.result {
            case .success:
                if let resp_obj = response.result.value {
                    if resp_obj.auth_result == true {
                        completionHandler(true, resp_obj.session_id, "ok")
                    } else {
                        completionHandler(false, nil, "可能因为用户名密码不正确，或教务系统太烂无法通信，请稍后再试")
                    }
                }
            default:
                completionHandler(false, nil, "教务系统太烂无法通信，请稍后再试")
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
            case .success:
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "连接学校服务器超时")
            }
        }
    }

    // Get class schedule, current term
    static func classSchedule(session_id: String, student_id: String?,
                              completionHandler: @escaping (ClassData?, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["session_id": session_id];
        if let v = student_id { params["student_id"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/class/term", parameters: params).responseObject(keyPath: "result") { (response: DataResponse<ClassData>) in
            switch response.result {
            case .success:
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "连接学校服务器超时")
            }
        }
    }

    // Filter class sessions by day
    static func classSessions(data: [ClassSession], dayInWeek: Int) -> [ClassSession] {
        var result: [ClassSession] = []
        for session in data {
            if dayInWeek == session.day_of_week {
                result.append(session)
            }
        }
        return result.sorted { $0.classes_in_day < $1.classes_in_day }
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
            case .success:
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "连接学校服务器超时")
            }
        }
    }
}

class AuthInitResponse: Mappable {
    var session_id: String?
    var captcha_enabled: Bool!
    var message: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        session_id      <- map["result.session_id"]
        captcha_enabled <- map["result.captcha_enabled"]
        message         <- map["message"]
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

class ClassData: Mappable {
    var current_week: Int!
    var classes: [[ClassSession]]!

    required init?(map: Map) {}

    func mapping(map: Map) {
        current_week <- map["current_week"]
        classes      <- map["classes"]
    }
}

class ClassSession: Mappable {
    var week: Int!
    var day_of_week: Int!
    var classes_in_day: String!
    var title: String!
    var instructor: String!
    var location: String!
    var type: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        week           <- map["week"]
        day_of_week    <- map["day_of_week"]
        classes_in_day <- map["classes_in_day"]
        title          <- map["title"]
        instructor     <- map["instructor"]
        location       <- map["location"]
        type           <- map["type"]
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
