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

    private func dateString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd • EEEE"
        return fmt.string(from: Date())
    }

    private func displayClassData() {
        // Extract today's sessions
        let data_classes = self.data_classes!
        let current_week = data_classes.classes[data_classes.current_week]
        self.data_today_sessions = SchoolSystemModels.classSessions(data: current_week, dayInWeek: SAUtils.dayOfWeek())
        if self.data_today_sessions.count == 0 {
            self.lblCenter.text = "没有课 🎉"
        } else {
            self.lblCenter.text = ""
        }

        // Refresh tableview
        self.tableView.reloadData()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // Check if saved student_login / password available
        let student_login = SAUtils.readLocalKVStore(key: "student_login")
        let student_password = SAUtils.readLocalKVStore(key: "student_password")

        if student_login == nil || student_password == nil {
            lblCenter.text = "请先使用 MyGDUT App 登录"
            completionHandler(NCUpdateResult.newData)
            return
        }

        // Get date string
        let date_string = dateString()
        lblTitle.text = date_string

        // Determine if update is not needed
        if let last_updated_date_string = SAUtils.readLocalKVStore(key: "class-widget-last-updated") {
            if date_string == last_updated_date_string {
                if let json = SAUtils.readLocalKVStore(key: "data_classes") {
                    self.data_classes = ClassData(JSONString: json)
                    self.displayClassData()
                    completionHandler(NCUpdateResult.newData)
                    return
                }
            }
        }

        // Fetch data from backend
        // Init
        SAUtils.initInstallationID()

        // Login
        loginWithSavedCredentials(student_login: student_login!, student_password: student_password!) { (success) in
            if success {
                // Logged in, fetch class schedule
                self.fetchClassSchedule(completionHandler: { (success) in
                    if success {
                        // Cache data
                        SAUtils.writeLocalKVStore(key: "class-widget-last-updated", val: date_string)
                        SAUtils.writeLocalKVStore(key: "data_classes", val: self.data_classes!.toJSONString())

                        // Update UI
                        self.displayClassData()
                        completionHandler(NCUpdateResult.newData)
                    } else {
                        self.lblCenter.text = "获取课程表失败"
                        completionHandler(NCUpdateResult.newData)
                    }
                })
            } else {
                self.lblCenter.text = "登录失败"
                completionHandler(NCUpdateResult.newData)
            }
        }
    }

    private func loginWithSavedCredentials(student_login: String, student_password: String, completionHandler: @escaping (Bool) -> Void) {
        // Execute
        SchoolSystemModels.submitAuthInfo(installation_id: SAGlobal.installation_id, student_login: student_login, student_password: student_password, captcha: nil, completionHandler: { (session_id, message) in

            if session_id != nil {
                // Store and cache session_id
                SAGlobal.student_session_id = session_id
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }

    private func fetchClassSchedule(completionHandler: @escaping (Bool) -> Void) {
        // Fetch clases
        if let session_id = SAGlobal.student_session_id {
            SchoolSystemModels.classSchedule(session_id: session_id, student_id: nil) { (data, message) in
                if let classes: ClassData = data {
                    SAUtils.writeLocalKVStore(key: "data_classes", val: classes.toJSONString())
                    self.data_classes = classes
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        } else {
            completionHandler(false)
        }
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
