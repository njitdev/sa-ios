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

class LibraryViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtKeyword: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actLoading: UIActivityIndicatorView!

    var data_books: [Book] = []
    var selected_book: Book?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "LibraryViewController";

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        // Focus on search text box at start
        txtKeyword.becomeFirstResponder()
    }

    @IBAction func txtKeywordPrimaryAction(_ sender: Any) {
        // User tap "Search" on keyboard

        // Clear current data
        data_books = []
        tableView.reloadData()
        setUIBusy(true)

        // Hide keyboard
        txtKeyword.resignFirstResponder()

        // Perform search
        LibraryModels.search(keyword: txtKeyword.text!, page: 0) { (books, message) in
            self.setUIBusy(false)

            if let books = books {
                self.data_books = books
                self.tableView.reloadData()
            } else {
                SAUtils.alert(viewController: self, title: "错误", message: message)
                return
            }
        }
    }

    func setUIBusy(_ busy: Bool) {
        txtKeyword.isEnabled = !busy
        if (busy) {
            actLoading.startAnimating()
        } else {
            actLoading.stopAnimating()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let details_vc = segue.destination as? BookDetailsViewController {
            details_vc.data_book = selected_book
        }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_books.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryTableViewCell", for: indexPath) as! LibraryTableViewCell

        let book = data_books[indexPath.row]
        cell.lblTitle.text = book.title
        cell.lblAuthor.text = book.author
        cell.lblAcquisitionNumber.text = book.acquisition_number

        // Composed optional values
        let year = book.year ?? ""
        let publisher = book.publisher ?? ""
        cell.lblPublisher.text = String(format: "%@ %@", year, publisher)

        let inventory = book.inventory ?? ""
        let available = book.available ?? ""
        cell.lblInventory.text = String(format: "馆藏: %@ 可借: %@", inventory, available)

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Temporarily store the book to be passed
        selected_book = data_books[indexPath.row]

        // Execute segue
        performSegue(withIdentifier: "segBookDetails", sender: self)
    }
}
