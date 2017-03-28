//
//  MessageBoardModels.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/21/17.
//

import UIKit
import Alamofire

class MessageBoardModels: NSObject {
    // Fetch posts by page
    static func fetchPosts(page: Int, completionHandler: @escaping ([MessageBoardPost]?) -> Void) {
        // Prepare parameters
        let params: Parameters = ["page": page];

        // Make request
        Alamofire.request(SAConfig.APIBaseURL + "/app/msgboard/posts", parameters: params).responseJSON { (response) in
            // Return nil on failure
            if (!(response.response?.statusCode == 200)) {
                completionHandler(nil);
                return;
            }

            if let r_value = response.result.value {
                // Downcasting
                let r_dict = r_value as! NSDictionary

                // Extract array
                let r_posts = r_dict.value(forKey: "posts") as! [Dictionary<String, Any>];

                // Create empty result array
                var result: [MessageBoardPost] = [];

                // Loop through items
                for r_post in r_posts {

                    // Initialize with required properties
                    let post = MessageBoardPost(user_name: r_post["user_name"] as! String, text: r_post["text"] as! String)

                    // Assign optional properties
                    post.id = r_post["id"] as? Int;
                    post.user_title = r_post["user_title"] as? String;
                    post.user_contact = r_post["user_contact"] as? String;
                    post.user_department = r_post["user_department"] as? String;

                    // Add to result array
                    result.append(post);
                }
                // Return result successfully
                completionHandler(result);
                return;
            }

            // Fail by default
            completionHandler(nil);
        }
    }
}

class MessageBoardPost: NSObject {
    public var id: Int?                 // Post ID (generated on server side)
    public var session_id: String?      // Session ID (generated on client side at each start)
    public var user_name: String        // Nickname
    public var text: String             // Text
    public var user_title: String?      // User title for team members
    public var user_contact: String?    // User contact
    public var user_student_id: String? // Student ID
    public var user_department: String? // Department

    // Initializer
    init(user_name: String, text: String) {
        self.user_name = user_name;
        self.text = text;
    }
}