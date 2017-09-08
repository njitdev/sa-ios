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
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCenter: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var data_classes: ClassData?
    private var data_today_sessions: [ClassSession] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        }
    }

    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = CGSize(width: 320, height: 110)
        } else {
            self.preferredContentSize = CGSize(width: 320, height: 300)
        }
    }

    private func dateString(_ currentWeek: Int) -> String {
        let fmt = DateFormatter()
        if (currentWeek > 0) {
            fmt.dateFormat = "MM-dd • 第\(currentWeek)周 • EEEE"
        } else {
            fmt.dateFormat = "MM-dd • EEEE"
        }
        return fmt.string(from: Date())
    }

    private func displayClassData() {
        // Extract today's sessions
        let data_classes = self.data_classes!

        // Index out-of-bound bug
        let current_week = SchoolSystemModels.safeCurrentWeek(data_classes)
        let _classes_current_week = data_classes.classes[current_week]

        self.data_today_sessions = SchoolSystemModels.classSessions(data: _classes_current_week, dayInWeek: SAUtils.dayOfWeek())
        if self.data_today_sessions.count == 0 {
            self.lblCenter.text = "没有课 🎉"
        } else {
            self.lblCenter.text = ""
        }

        // Refresh tableview
        self.tableView.reloadData()

        // Update title label
        let date_string = dateString(current_week)
        lblTitle.text = date_string
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // Check if saved student_login / password available
        if let json = SAUtils.readLocalKVStore(key: "data_classes") {
            self.data_classes = ClassData(JSONString: json)
        } else {
            lblCenter.text = "请先登录 App 更新课表~"
            completionHandler(NCUpdateResult.newData)
            return
        }

        self.displayClassData()
        completionHandler(NCUpdateResult.newData)
    }

    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_today_sessions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassWidgetTableCell", for: indexPath)

        let session = data_today_sessions[indexPath.row]
        if let lblTitle = cell.textLabel {
            lblTitle.textColor = UIColor.darkGray
            lblTitle.font = UIFont.systemFont(ofSize: 14)
            lblTitle.minimumScaleFactor = 0.5

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

            lblTitle.text = "• " + session_text + "节, " + session.location + ", " + session.title
        }

        return cell
    }
}
