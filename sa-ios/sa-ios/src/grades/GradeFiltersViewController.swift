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

class GradeFiltersViewController: UITableViewController {

    // Parent ViewController for passing data back
    public var parent_vc: GradesViewController?

    // Data
    public var data_grades: [GradeItem] = []
    private var data_grades_filtered: [GradeItem] = []

    // Filters
    private var filter_terms_available: [String] = []
    private var filter_terms_selected: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.generateFilters()
        self.tableView.reloadData()

        // Google Analytics
        SAUtils.GAISendScreenView("GradeFiltersViewController")
    }

    @IBAction func btnResetAction(_ sender: Any) {
        self.applyFilters(reset: true)
    }

    @IBAction func btnApplyAction(_ sender: Any) {
        if filter_terms_selected.count == 0 {
            SAUtils.alert(viewController: self, title: "没有选中任何学期 🤔", message: "如果需要选择所有成绩，请点'重置'")
            return
        }

        self.applyFilters()
    }

    private func generateFilters() {
        // Collect available terms in a set
        var terms: Set<String> = []
        for g in data_grades {
            if let term = g.term {
                if !terms.contains(term) {
                    terms.insert(term)
                }
            }
        }

        // Convert to an array and sort
        self.filter_terms_available = Array(terms)
        self.filter_terms_available.sort()
    }

    private func applyFilters(reset: Bool = false) {
        // Clear destination
        self.data_grades_filtered.removeAll()

        // term filter
        for g in data_grades {
            if let t = g.term {
                if filter_terms_selected.contains(t) {
                    self.data_grades_filtered.append(g)
                }
            }
        }

        // Select all if reset is requested
        if reset {
            self.data_grades_filtered = self.data_grades
        }

        // Pass data back
        self.parent_vc!.data_grades_filtered = self.data_grades_filtered

        // Return to grades screen
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let term = self.filter_terms_available[indexPath.row]
        if filter_terms_selected.contains(term) {
            filter_terms_selected.remove(at: filter_terms_selected.index(of: term)!)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        } else {
            filter_terms_selected.append(term)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "按学期筛选"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filter_terms_available.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradeFilterTableCell", for: indexPath)

        let term = self.filter_terms_available[indexPath.row]
        cell.textLabel?.text = term
        if filter_terms_selected.contains(term) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }
}
