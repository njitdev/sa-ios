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

class BookDetailsViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblPublisher: UILabel!
    @IBOutlet weak var lblInventory: UILabel!
    @IBOutlet weak var lblAcquisitionNumber: UILabel!
    @IBOutlet weak var actLoading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var data_book: Book?
    var data_book_details: BookDetails?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "BookDetailsViewController";

        tableView.delegate = self
        tableView.dataSource = self

        // Fill basic info of book obj from list
        if let book = data_book {
            lblTitle.text = book.title
            lblAuthor.text = book.author
            lblAcquisitionNumber.text = book.acquisition_number

            // Composed optional values
            let year = book.year ?? ""
            let publisher = book.publisher ?? ""
            lblPublisher.text = String(format: "%@ %@", year, publisher)

            let inventory = book.inventory ?? ""
            let available = book.available ?? ""
            lblInventory.text = String(format: "馆藏: %@ 可借: %@", inventory, available)

            // Fetch details
            actLoading.startAnimating()
            LibraryModels.details(book_id: book.id, completionHandler: { (details, message) in
                self.actLoading.stopAnimating()

                if let details = details {
                    self.data_book_details = details
                    self.tableView.reloadData()
                } else {
                    SAUtils.alert(viewController: self, title: "没有查询到馆藏 😛", message: "换本书试试看")
                    return;
                }
            })
        }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (data_book_details == nil) { return 0 }
        return data_book_details!.inventory.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookInventoryTableCell", for: indexPath) as! BookInventoryTableCell

        let inventory = data_book_details!.inventory[indexPath.row]
        cell.lblLocation.text = inventory.location
        cell.lblLoginNumber.text = inventory.login_number
        cell.lblAvailability.text = inventory.availability
        cell.lblType.text = inventory.type

        return cell
    }
}
