//
//  HomeViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var btnToggleLogin: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = SAConfig.appName
    }

    override func viewWillAppear(_ animated: Bool) {
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
            btnToggleLogin.title = "退出"
        } else {
            btnToggleLogin.title = "登录"
        }
    }
}
