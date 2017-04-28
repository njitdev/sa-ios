//
//  HomeViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//

import UIKit

class HomeViewController: UITableViewController {

    @IBOutlet weak var lblStudentName: UILabel!
    @IBOutlet weak var lblLoginInformation: UILabel!

    @IBOutlet weak var actLogin: UIActivityIndicatorView!
    @IBOutlet weak var actClassSchedule: UIActivityIndicatorView!
    @IBOutlet weak var actGrades: UIActivityIndicatorView!
    @IBOutlet weak var actExamSchedule: UIActivityIndicatorView!

    private var lastSessionID = ""
    private var isFetchingData = false

    // School system data
    private var data_student_basic_info: StudentBasicInfo?
    private var data_grades: [GradeItem]?

    // MARK: UI events
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = SAConfig.appName
    }

    override func viewWillAppear(_ animated: Bool) {
        updateLoginStatus()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: UI logic
    func updateLoginStatus() {
        if let session_id = SAGlobal.user_session_id {
            // Fetch student basic info if just logged in
            if lastSessionID != session_id { fetchSchoolSystemData(false) }
            lastSessionID = session_id
        } else {
            lastSessionID = ""
            fetchSchoolSystemData(true)
        }
    }

    func displaySchoolSystemInfo() {
        if let basic_info = self.data_student_basic_info {
            // Name
            self.lblStudentName.text = basic_info.student_name

            var login_info = "" + basic_info.student_department
            if let v = basic_info.student_enroll_year { login_info = login_info + ", " + v + " 级" }
            self.lblLoginInformation.text = login_info
        } else {
            lblStudentName.text = "教务系统"
            lblLoginInformation.text = "点这里登录"
        }
    }

    // MARK: Data management
    func fetchSchoolSystemData(_ fromCache: Bool) {
        // Fetch from cache
        if fromCache {
            if let json = SAUtils.readLocalKVStore(key: "data_student_basic_info") {
                self.data_student_basic_info = StudentBasicInfo(JSONString: json)
            }

            if let json = SAUtils.readLocalKVStore(key: "data_grades") {
                self.data_grades = [GradeItem](JSONString: json)
            }

            self.displaySchoolSystemInfo()
            return;
        }

        // Fetch from backend
        // UI Loading state
        actLogin.startAnimating()
        actGrades.startAnimating()
        lblStudentName.text = "登录中"
        lblLoginInformation.text = "正在获取数据"

        let session_id = SAGlobal.user_session_id!

        // Basic info
        SchoolSystemModels.studentBasicInfo(session_id: session_id, student_id: nil) { (data, message) in
            self.actLogin.stopAnimating()
            if let basic_info = data {
                // Cache data
                SAUtils.writeLocalKVStore(key: "data_student_basic_info", val: basic_info.toJSONString())

                // Process locally
                self.data_student_basic_info = basic_info
                self.displaySchoolSystemInfo()
            } else {
                SAUtils.alert(viewController: self, title: "无法获取数据", message: message + "\n请重新登录");
            }
        }

        // Fetch grades
        SchoolSystemModels.grades(session_id: session_id, student_id: nil) { (data, message) in
            self.actGrades.stopAnimating()
            if let grades = data {
                SAUtils.writeLocalKVStore(key: "data_grades", val: grades.toJSONString())
                self.data_grades = grades
            }
        }
    }

    // MARK: Navigation logic
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "segLogin":
            return !self.actLogin.isAnimating
        case "segGrades":
            if self.data_grades == nil {
                SAUtils.alert(viewController: self, title: "没有数据", message: "请先登录教务系统")
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
        case "segGrades":
            if let vc_grades = segue.destination as? GradesViewController {
                vc_grades.data_grades = self.data_grades!
            }
        default:
            break
        }
    }
}
