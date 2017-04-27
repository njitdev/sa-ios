//
//  MessageBoardModels.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/21/17.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class MessageBoardModels: NSObject {
    // Message Board base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/app/msgboard/" + SAConfig.schoolIdentifier

    // Fetch posts by page
    static func fetchPosts(page: Int, completionHandler: @escaping ([MessageBoardPost]?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["page": page]

        // Make request
        Alamofire.request(apiBaseURL + "/posts", parameters: params).responseObject { (response: DataResponse<MessageBoardListResponse>) in
            // Response status validation
            switch response.result {
            case .success(_):
                let resp_obj = response.result.value
                if let posts = resp_obj?.posts {
                    completionHandler(posts, "ok")
                } else {
                    completionHandler(nil, "数据解析错误")
                }
            default:
                completionHandler(nil, "网络通信错误")
            }
        }
    }

    // Submit new post
    static func submitPost(post: MessageBoardPost, user_student_id: String?, completionHandler: @escaping (Bool, String) -> Void) {
        // Prepare parameters
        var params: Parameters = ["user_name": post.user_name, "text": post.text]

        // Assign optional values
        if let v = post.installation_id { params["installation_id"] = v }
        if let v = post.user_contact    { params["user_contact"]    = v }
        if let v = user_student_id      { params["user_student_id"] = v }

        // Make request
        Alamofire.request(self.apiBaseURL + "/posts", method: .post, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completionHandler(true, "ok")
            default:
                completionHandler(false, "网络通信错误")
            }
        }
    }
}

class MessageBoardListResponse: Mappable {
    var posts: [MessageBoardPost]?
    var page_num: Int?
    var message: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        posts    <- map["result.posts"]
        page_num <- map["result.page_num"]
        message  <- map["message"]
    }
}

class MessageBoardPost: Mappable {
    public var _id: String?             // Post ID (generated on server side)
    public var installation_id: String? // Installation ID (generated on client side at first start)
    public var user_name: String!       // Nickname
    public var text: String!            // Text
    public var user_title: String?      // User title for team members
    public var user_contact: String?    // User contact
    public var user_student_id: String? // Student ID
    public var user_department: String? // Department

    required init?(map: Map) {}

    // For creating object without JSON
    init(user_name: String, text: String) {
        self.user_name = user_name
        self.text = text
    }

    func mapping(map: Map) {
        _id             <- map["_id"]
        installation_id <- map["installation_id"]
        user_name       <- map["user_name"]
        text            <- map["text"]
        user_title      <- map["user_title"]
        user_contact    <- map["user_contact"]
        user_student_id <- map["user_student_id"]
        user_department <- map["user_department"]
    }
}
