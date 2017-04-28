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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = SAConfig.appName
    }

    override func viewWillAppear(_ animated: Bool) {
        // Deselect rows
        if let selected_indexpath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selected_indexpath, animated: true)
        }

        updateLoginStatus()
    }

    @IBAction func btnToggleLoginAction(_ sender: UIBarButtonItem) {
        if SAGlobal.user_session_id != nil {
            SAGlobal.user_session_id = nil
            updateLoginStatus()
        } else {
            performSegue(withIdentifier: "segLogin", sender: self);
        }
    }

    func updateLoginStatus() {
        if SAGlobal.user_session_id != nil {

        } else {
            lblStudentName.text = "教务系统"
            lblLoginInformation.text = "未登录"
        }
    }
}
