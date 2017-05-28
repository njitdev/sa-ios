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

class AnnouncementsModels: NSObject {
    // School system base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/school/" + SAConfig.schoolIdentifier

    // Announcement list
    static func list(category: String, completionHandler: @escaping ([AnnouncementListItem]?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["category": category]

        // Make request
        Alamofire.request(apiBaseURL + "/announcements", parameters: params).responseArray(keyPath: "result") { (response: DataResponse<[AnnouncementListItem]>) in
            // Response status validation
            switch response.result {
            case .success(_):
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "网络通信错误")
            }
        }
    }

    // Get article
    static func article(article_id: String, completionHandler: @escaping (AnnouncementsArticle?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["article_id": article_id];

        // Make request
        Alamofire.request(self.apiBaseURL + "/announcements/article", parameters: params).responseObject(keyPath: "result") { (response: DataResponse<AnnouncementsArticle>) in
            switch response.result {
            case .success(_):
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "网络通信错误")
            }
        }
    }
}

class AnnouncementListItem: Mappable {
    var article_id: String!
    var article_title: String!
    var article_department: String?
    var article_date: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        article_id         <- map["article_id"]
        article_title      <- map["article_title"]
        article_department <- map["article_department"]
        article_date       <- map["article_date"]
    }
}

class AnnouncementsArticle: Mappable {
    var article_body: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        article_body <- map["article_body"]
    }
}
