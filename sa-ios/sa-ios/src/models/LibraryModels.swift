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

class LibraryModels: NSObject {
    // Library base URL
    private static let apiBaseURL = SAConfig.APIBaseURL + "/library/" + SAConfig.schoolIdentifier

    // Search for books
    static func search(keyword: String, page: Int, completionHandler: @escaping ([Book]?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["keyword": keyword, "page": page]

        // Make request
        Alamofire.request(apiBaseURL + "/search", parameters: params).responseArray(keyPath: "result") { (response: DataResponse<[Book]>) in
            // Response status validation
            switch response.result {
            case .success(_):
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "连接学校服务器超时")
            }
        }
    }

    // Get book details
    static func details(book_id: String, completionHandler: @escaping (BookDetails?, String) -> Void) {
        // Prepare parameters
        let params: Parameters = ["book_id": book_id];

        // Make request
        Alamofire.request(self.apiBaseURL + "/details", parameters: params).responseObject(keyPath: "result") { (response: DataResponse<BookDetails>) in
            switch response.result {
            case .success(_):
                completionHandler(response.result.value, "ok")
            default:
                completionHandler(nil, "连接学校服务器超时")
            }
        }
    }
}

class Book: Mappable {
    var id: String!
    var title: String!
    var author: String?
    var publisher: String?
    var year: String?
    var acquisition_number: String?
    var inventory: String?
    var available: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id                 <- map["id"]
        title              <- map["title"]
        author             <- map["author"]
        publisher          <- map["publisher"]
        year               <- map["year"]
        acquisition_number <- map["acquisition_number"]
        inventory          <- map["inventory"]
        available          <- map["available"]
    }
}

class BookDetails: Mappable {
    var inventory: [BookInventory]!

    required init?(map: Map) {}

    func mapping(map: Map) {
        inventory <- map["inventory"]
    }
}

class BookInventory: Mappable {
    var location: String!
    var acquisition_number: String!
    var login_number: String?
    var year: String?
    var availability: String?
    var type: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        location           <- map["location"]
        acquisition_number <- map["acquisition_number"]
        login_number       <- map["login_number"]
        year               <- map["year"]
        availability       <- map["availability"]
        type               <- map["type"]
    }
}
