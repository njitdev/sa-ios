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

class AnnouncementsArticleViewController: GAITrackedViewController {

    @IBOutlet weak var webArticle: UIWebView!
    @IBOutlet weak var actLoading: UIActivityIndicatorView!

    var data_article_list_item: AnnouncementListItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "AnnouncementsArticleViewController"

        if let list_item = data_article_list_item {
            AnnouncementsModels.article(article_id: list_item.article_id, completionHandler: { (article, message) in
                self.actLoading.stopAnimating()
                self.webArticle.isUserInteractionEnabled = true

                if let article = article {
                    self.webArticle.loadHTMLString(article.article_body, baseURL: nil)
                } else {
                    SAUtils.alert(viewController: self, title: "错误 😛", message: message)
                    return
                }
            })
        }
    }
}
