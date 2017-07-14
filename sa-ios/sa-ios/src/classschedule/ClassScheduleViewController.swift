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

class ClassScheduleViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnPrevWeek: UIBarButtonItem!
    @IBOutlet weak var btnNextWeek: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var data_classes: ClassData!
    private var data_classes_display_week: [ClassSession] = []
    private var data_display_week = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "ClassScheduleViewController"

        tableView.delegate = self
        tableView.dataSource = self

        data_display_week = data_classes.current_week
        displayClasses()
    }

    @IBAction func btnPrevWeekAct(_ sender: Any) {
        if data_display_week <= 1 { return }
        data_display_week -= 1
        displayClasses()
    }

    @IBAction func btnNextWeekAct(_ sender: Any) {
        if data_display_week >= (data_classes.classes.count - 1) { return }
        data_display_week += 1
        displayClasses()
    }

    func displayClasses() {
        if (data_display_week >= data_classes.classes.count) {
            data_classes_display_week = []
        } else {
            data_classes_display_week = data_classes.classes[data_display_week]
        }

        tableView.reloadData()
        self.navigationItem.title = "课表 (\(data_display_week)周)"
    }

    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "周一"
        case 1:
            return "周二"
        case 2:
            return "周三"
        case 3:
            return "周四"
        case 4:
            return "周五"
        case 5:
            return "周六"
        case 6:
            return "周日"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SchoolSystemModels.classSessions(data: data_classes_display_week, dayInWeek: section + 1).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassSessionTableCell", for: indexPath) as! ClassSessionTableCell

        let sessions = SchoolSystemModels.classSessions(data: data_classes_display_week, dayInWeek: indexPath.section + 1)
        let session = sessions[indexPath.row]

        cell.lblTitle.text = session.title
        cell.lblInstructor.text = session.instructor
        cell.lblLocation.text = session.location

        // Re-format session text
        var session_text = ""
        let nums = session.classes_in_day.components(separatedBy: ",")
        for num in nums {
            if let n = Int(num) {
                session_text.append("\(n),")
            }
        }
        if !session_text.isEmpty {
            session_text.remove(at: session_text.index(before: session_text.endIndex))
        }
        cell.lblSessionNumber.text = session_text

        return cell
    }
}
