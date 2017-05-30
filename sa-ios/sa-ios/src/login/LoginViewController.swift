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

class LoginViewController: UITableViewController {

    @IBOutlet weak var txtStudentLogin: UITextField!
    @IBOutlet weak var txtStudentPassword: UITextField!
    @IBOutlet weak var swAutoLogin: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var actBusy: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        SAUtils.GAISendScreenView("LoginViewController")

        // Read saved login / password
        if let student_login = SAUtils.readLocalKVStore(key: "student_login"),
            let student_password = SAUtils.readLocalKVStore(key: "student_password") {
            txtStudentLogin.text = student_login
            txtStudentPassword.text = student_password
        }

        autoEnableLoginButton();
    }

    @IBAction func txtStudentLoginPrimaryAction(_ sender: Any) {
        txtStudentPassword.becomeFirstResponder()
    }

    @IBAction func txtStudentPasswordPrimaryAction(_ sender: Any) {
        if (btnLogin.isEnabled) {
            self.btnLoginAction(btnLogin)
        }
    }

    @IBAction func txtValueChanged(_ sender: Any) {
        autoEnableLoginButton();
    }

    @IBAction func btnLoginAction(_ sender: Any) {
        self.setBusyState(true)

        SchoolSystemModels.submitAuthInfo(student_login: txtStudentLogin.text!, student_password: txtStudentPassword.text!, captcha: nil) { (session_id, message) in
            self.setBusyState(false)

            if session_id != nil {
                // Set session_id
                SAGlobal.user_session_id = session_id!

                // Save login / password
                SAUtils.writeLocalKVStore(key: "student_login", val: self.txtStudentLogin.text!)
                SAUtils.writeLocalKVStore(key: "student_password", val: self.txtStudentPassword.text!)

                // Return to home page
                self.navigationController?.popViewController(animated: true)
            } else {
                SAUtils.alert(viewController: self, title: "登录失败", message: message)
            }
        }
    }

    func autoEnableLoginButton() {
        if (txtStudentLogin.text!.characters.count > 0 &&
            txtStudentPassword.text!.characters.count > 0) {
            btnLogin.isEnabled = true;
        } else {
            btnLogin.isEnabled = false;
        }
    }

    func setBusyState(_ busy: Bool) {
        self.tableView.isUserInteractionEnabled = !busy
        btnLogin.isEnabled = !busy
        busy ? actBusy.startAnimating() : actBusy.stopAnimating()
    }
}
