//
//  MessageBoardModels.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/21/17.
//

import UIKit
import Alamofire

class MessageBoardModels: NSObject {
    // Message Board base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/app/msgboard/" + SAConfig.schoolIdentifier

    // Fetch posts by page
    static func fetchPosts(page: Int, completionHandler: @escaping ([MessageBoardPost]?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["page": page]

        // Make request
        Alamofire.request(self.apiBaseURL + "/posts", parameters: params).responseJSON { (response) in
            // Response status validation
            switch response.result {
            case .success(_):

                // Extract array
                let r_dict = response.result.value as? [String: Any]
                let r_result = r_dict?["result"] as? [String: Any]
                let r_posts = r_result?["posts"] as? [[String: Any]]

                // Create empty result array
                var result: [MessageBoardPost] = []

                // Loop through items
                for r_post in r_posts ?? [] {

                    // Initialize with required properties
                    let post = MessageBoardPost(user_name: r_post["user_name"] as! String,
                                                text: r_post["text"] as! String)

                    // Assign optional properties
                    post._id = r_post["_id"] as? String
                    post.user_title = r_post["user_title"] as? String
                    post.user_contact = r_post["user_contact"] as? String
                    post.user_department = r_post["user_department"] as? String

                    // Add to result array
                    result.append(post)
                }
                // Return result successfully
                completionHandler(result, "ok")
                return

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

class MessageBoardPost: NSObject {
    public var _id: String?             // Post ID (generated on server side)
    public var installation_id: String? // Installation ID (generated on client side at first start)
    public var user_name: String        // Nickname
    public var text: String             // Text
    public var user_title: String?      // User title for team members
    public var user_contact: String?    // User contact
    public var user_student_id: String? // Student ID
    public var user_department: String? // Department

    // Initializer
    init(user_name: String, text: String) {
        self.user_name = user_name
        self.text = text
    }
}
