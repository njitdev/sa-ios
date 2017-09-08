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
import OneSignal

class HomeViewController: UITableViewController {

    @IBOutlet weak var btnAbout: UIBarButtonItem!
    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    @IBOutlet weak var btnLogin: UIButton!

    @IBOutlet weak var lblStudentName: UILabel!
    @IBOutlet weak var lblLoginInformation: UILabel!
    @IBOutlet weak var lblClassScheduleTitle: UILabel!
    @IBOutlet weak var lblClassScheduleSubtitle: UILabel!
    @IBOutlet weak var lblGradesTitle: UILabel!
    @IBOutlet weak var lblGradesSubtitle: UILabel!

    @IBOutlet weak var actLogin: UIActivityIndicatorView!
    @IBOutlet weak var actClassSchedule: UIActivityIndicatorView!
    @IBOutlet weak var actGrades: UIActivityIndicatorView!
    @IBOutlet weak var actExamSchedule: UIActivityIndicatorView!

    private var lastSessionID = ""
    private var isFetchingData = false

    // School system data
    private var data_student_basic_info: StudentBasicInfo?
    private var data_classes: ClassData?
    private var data_grades: [GradeItem]?

    // MARK: UI events
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = SAConfig.appName

        // Google Analytics
        SAUtils.GAISendScreenView("HomeViewController")

        // Load saved session_id
        SAGlobal.student_session_id = SAUtils.readLocalKVStore(key: "student_session_id")

        // Load cached data
        loadCachedData()

        // Set lastSessionID to disable auto fetching
        lastSessionID = SAGlobal.student_session_id ?? ""

        // Push notifications
        // Get permission status
        let push_status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if !push_status.permissionStatus.hasPrompted {
            // Prompt
            SAUtils.alert(viewController: self, title: "推送通知 🤖", message: "我们未来会推送:\n\n校园的重要通知\n考试、成绩提醒\n\n永远不会有广告🙂", handler: { (_) in
                OneSignal.promptForPushNotifications(userResponse: { accepted in })
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Update data
        autoUpdateData()

        // Update about button
        let emojis = ["🤔", "🐳", "🐹", "🚀", "🏞", "🍭", "🍄", "🎹", "🎉", "🚗", "⛵", "🍀", "🍁", "🌸", "💾", "🤖", "🙃", "👾", "🎓", "💰", "⚽"]
        UIView.performWithoutAnimation {
            btnAbout.title = emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
        }
    }

    @IBAction func btnRefreshAct(_ sender: Any) {
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()

        // Force re-fetch data
        lastSessionID = ""
        autoUpdateData()
    }

    private func enableActionButtons(_ enable: Bool) {
        btnRefresh.isEnabled = enable
        btnLogin.isEnabled = enable
    }

    private func displaySchoolSystemData() {
        if let basic_info = self.data_student_basic_info {
            btnLogin.setTitle("重新登录", for: UIControlState.normal)

            // Basic info
            self.lblStudentName.text = basic_info.student_name
            var login_info = "" + basic_info.student_department
            if let v = basic_info.student_enroll_year { login_info = login_info + ", " + v + " 级" }
            self.lblLoginInformation.text = login_info
        } else {
            btnRefresh.isEnabled = false
            btnLogin.setTitle("登录", for: UIControlState.normal)
            lblStudentName.text = "教务系统"
            lblLoginInformation.text = "未登录"
        }

        if let classes = data_classes {
            lblClassScheduleTitle.center.y = 24.5
            lblClassScheduleSubtitle.isHidden = false

            // Get classes of current week
            let current_week = SchoolSystemModels.safeCurrentWeek(classes)
            let _classes_current_week = classes.classes[current_week]

            let cnt = SchoolSystemModels.classSessions(data: _classes_current_week, dayInWeek: SAUtils.dayOfWeek()).count
            if (cnt == 0) {
                lblClassScheduleSubtitle.text = "今日课程: 无 🎉"
            } else {
                lblClassScheduleSubtitle.text = "今日课程: \(cnt)"
            }
        } else {
            lblClassScheduleTitle.center.y = 34.5
            lblClassScheduleSubtitle.isHidden = true
        }

        if let grades = data_grades {
            lblGradesTitle.center.y = 24.5
            lblGradesSubtitle.isHidden = false
            lblGradesSubtitle.text = "\(grades.count) 门课程"
        } else {
            lblGradesTitle.center.y = 34.5
            lblGradesSubtitle.isHidden = true
        }
    }

    // MARK: Data management
    private func loadCachedData() {
        if let json = SAUtils.readLocalKVStore(key: "data_student_basic_info") {
            self.data_student_basic_info = StudentBasicInfo(JSONString: json)
        }

        if let json = SAUtils.readLocalKVStore(key: "data_classes") {
            self.data_classes = ClassData(JSONString: json)
        }

        if let json = SAUtils.readLocalKVStore(key: "data_grades") {
            self.data_grades = [GradeItem](JSONString: json)
        }

        self.displaySchoolSystemData()
    }

    private func autoUpdateData() {
        // 1. If session_id changed (new login or app startup), fetch basic info
        // 2. If successful, continue to fetch all data
        // 3. If failure, attempt to login
        // 4. If login successful, return to step 2, otherwise stop and prompt error.

        // No session_id (not logged in)
        if SAGlobal.student_session_id == nil {
            lastSessionID = ""
            displaySchoolSystemData()
            return
        }

        // session_id available
        let session_id = SAGlobal.student_session_id!

        if lastSessionID != session_id {
            lastSessionID = session_id

            // Disable action buttons
            enableActionButtons(false)

            // 1. session_id changed, fetch basic info (and validate login status)
            fetchBasicInfo(session_id: session_id, student_id: nil, completionHandler: { (success) in
                if (success) {
                    // 2. Continue
                    // Display login status
                    self.displaySchoolSystemData()

                    // Fetch and display all other data
                    self.fetchAndDisplayAllSchoolSystemData()
                } else {
                    // 3. Failed, attempt to login
                    self.loginWithSavedCredentials(completionHandler: { (success) in
                        // 4.
                        self.actLogin.stopAnimating()
                        if (success) {
                            self.fetchAndDisplayAllSchoolSystemData()
                        } else {
                            // End state, enable action buttons
                            self.enableActionButtons(true)
                            self.performSegue(withIdentifier: "segLogin", sender: self)
//                            SAUtils.alert(viewController: self, title: "无法自动登录 😛", message: "无验证码登录失败，需要重新登录")
                        }
                    })
                }
            })
        }
    }

    private func fetchBasicInfo(session_id: String, student_id: String?, completionHandler: @escaping (Bool) -> Void) {
        self.title = "正在更新数据..."
        self.actLogin.startAnimating()

        // Basic info
        SchoolSystemModels.studentBasicInfo(session_id: session_id, student_id: student_id) { (data, message) in
            self.actLogin.stopAnimating()

            if let basic_info = data {
                // Store and cache basic info
                self.data_student_basic_info = basic_info
                SAUtils.writeLocalKVStore(key: "data_student_basic_info", val: basic_info.toJSONString())

                self.title = SAConfig.appName
                completionHandler(true)
            } else {
                self.title = "基本信息获取失败"
                completionHandler(false)
            }
        }
    }

    private func loginWithSavedCredentials(completionHandler: @escaping (Bool) -> Void) {
        // Read saved credentials
        if let student_login = SAUtils.readLocalKVStore(key: "student_login"),
           let student_password = SAUtils.readLocalKVStore(key: "student_password") {

            // UI
            self.title = "登录中..."
            self.actLogin.startAnimating()

            // Execute
            SchoolSystemModels.submitAuthInfo(installation_id: SAGlobal.installation_id, session_id: nil, student_login: student_login, student_password: student_password, captcha: nil, completionHandler: { (success, session_id, message) in

                // UI
                self.actLogin.stopAnimating()

                if session_id != nil {
                    // Store and cache session_id
                    SAGlobal.student_session_id = session_id
                    SAUtils.writeLocalKVStore(key: "student_session_id", val: session_id)

                    // Set as session session_id
                    self.lastSessionID = session_id!

                    self.title = SAConfig.appName
                    completionHandler(true)
                } else {
                    self.title = "需重新登录"
                    completionHandler(false)
                }
            })
        } else {
            self.title = "需重新登录"
            completionHandler(false)
        }
    }

    private func fetchAndDisplayAllSchoolSystemData() {
        // UI Loading state
        self.title = "正在更新数据..."
        actGrades.startAnimating()
        actClassSchedule.startAnimating()

        let session_id = SAGlobal.student_session_id!

        // Counter
        var total = 2, completed = 0

        // Fetch clases
        SchoolSystemModels.classSchedule(session_id: session_id, student_id: nil) { (data, message) in

            self.actClassSchedule.stopAnimating()

            completed += 1
            if (completed == total) {
                self.enableActionButtons(true)
                self.title = SAConfig.appName
            }

            if let classes: ClassData = data {
                SAUtils.writeLocalKVStore(key: "data_classes", val: classes.toJSONString())
                self.data_classes = classes
            } else {
                self.title = "获取课程表失败"
                SAUtils.alert(viewController: self, title: "错误 😛", message: "获取课程表失败，请尝试重新登录")
            }

            self.displaySchoolSystemData()
        }

        // Fetch grades
        SchoolSystemModels.grades(session_id: session_id, student_id: nil) { (data, message) in

            self.actGrades.stopAnimating()

            completed += 1
            if (completed == total) {
                self.enableActionButtons(true)
                self.title = SAConfig.appName
            }

            if let grades: [GradeItem] = data {
                SAUtils.writeLocalKVStore(key: "data_grades", val: grades.toJSONString())
                self.data_grades = grades
            } else {
                self.title = "获取成绩失败"
                SAUtils.alert(viewController: self, title: "错误 😛", message: "获取成绩失败，请尝试重新登录")
            }

            self.displaySchoolSystemData()
        }
    }

    // MARK: Navigation logic
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "segLogin":
            // Force reload on return
//            lastSessionID = ""
            return !self.actLogin.isAnimating
        case "segClassSchedule":
            if self.data_classes == nil {
                SAUtils.alert(viewController: self, title: "没有数据 🤔", message: "请先登录教务系统")
                return false
            }
            return !self.actClassSchedule.isAnimating
        case "segGrades":
            if self.data_grades == nil {
                SAUtils.alert(viewController: self, title: "没有数据 🤔", message: "请先登录教务系统")
                return false
            }
            return !self.actGrades.isAnimating
        default:
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case "segLogin":
            break
        case "segClassSchedule":
            if let vc_class = segue.destination as? ClassScheduleViewController {
                vc_class.data_classes = self.data_classes!
            }
        case "segGrades":
            if let vc_grades = segue.destination as? GradesViewController {
                vc_grades.data_grades = self.data_grades!
            }
        default:
            break
        }
    }
}
