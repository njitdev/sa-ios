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

class AnnouncementsViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var segCategory: UISegmentedControl!
    @IBOutlet weak var actLoading: UIActivityIndicatorView!

    var data_list: [AnnouncementListItem] = []
    var selected_article: AnnouncementListItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "AnnouncementsViewController"

        tableview.delegate = self
        tableview.dataSource = self

        self.segCategoryChanged(segCategory)
    }

    func setUIBusy(_ busy: Bool) {
        segCategory.isEnabled = !busy
        tableview.isUserInteractionEnabled = !busy
        if (busy) {
            actLoading.startAnimating()
        } else {
            actLoading.stopAnimating()
        }
    }

    @IBAction func segCategoryChanged(_ sender: Any) {
        // Clear table
        self.data_list = []
        tableview.reloadData()

        // Fetch data
        setUIBusy(true)

        let category: String = String(segCategory.selectedSegmentIndex + 1)
        AnnouncementsModels.list(category: category) { (announcements, message) in
            self.setUIBusy(false)
            if let data = announcements {
                self.data_list = data
                self.tableview.reloadData()
            } else {
                SAUtils.alert(viewController: self, title: "错误", message: message)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let details_vc = segue.destination as? AnnouncementsArticleViewController {
            details_vc.data_article_list_item = selected_article!
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data_list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementsTableCell", for: indexPath)

        if let lblTitle = cell.textLabel, let lblSubtitle = cell.detailTextLabel {
            // Adjust style
            lblTitle.font = UIFont.systemFont(ofSize: 15)
            lblSubtitle.font = UIFont.systemFont(ofSize: 13)
            lblTitle.textColor = UIColor.darkGray
            lblSubtitle.textColor = UIColor.gray

            // Data
            let listItem = data_list[indexPath.row]
            lblTitle.text = listItem.article_title

            let department = listItem.article_department ?? ""
            let date = listItem.article_date ?? ""
            lblSubtitle.text = department + " " + date
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Temporarily store the list item to be passed
        selected_article = data_list[indexPath.row]

        // Execute segue
        performSegue(withIdentifier: "segAnnouncementsArticle", sender: self)
    }
}
