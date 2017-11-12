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

class LoginViewController: UITableViewController {

    @IBOutlet weak var txtStudentLogin: UITextField!
    @IBOutlet weak var txtStudentPassword: UITextField!
    @IBOutlet weak var tblCellCaptcha: UITableViewCell!
    @IBOutlet weak var txtCaptcha: UITextField!
    @IBOutlet weak var imgCaptcha: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var actBusy: UIActivityIndicatorView!

    private var captchaEnabled: Bool = false
    private var temp_session_id: String?

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

        // Init auth
        authInit()
    }

    private func authInit() {
        setBusyState(true)
        SchoolSystemModels.initAuth { (captchaEnabled, session_id, message) in
            self.setBusyState(false)
            if let session_id = session_id, let captchaEnabled = captchaEnabled {
                self.temp_session_id = session_id

                // Fetch captcha if enabled
                self.captchaEnabled = captchaEnabled
                if self.captchaEnabled {
                    self.fetchCaptcha()
                } else {
                    self.txtCaptcha.placeholder = "无需验证码"
                    self.tblCellCaptcha.isUserInteractionEnabled = false
                }
            } else {
                SAUtils.alert(viewController: self, title: "登录初始化失败 😑", message: message)
            }
        }
    }

    private func fetchCaptcha() {
        if let session_id = temp_session_id {
            setBusyState(true)
            SchoolSystemModels.fetchCaptcha(session_id: session_id, completionHandler: { (captcha, message) in
                self.setBusyState(false)
                if let captcha = captcha {
                    self.imgCaptcha.image = captcha
                } else {
                    SAUtils.alert(viewController: self, title: "登录初始化失败 😑", message: message)
                }
            })
        }
    }

    @IBAction func txtStudentLoginPrimaryAction(_ sender: Any) {
        txtStudentPassword.becomeFirstResponder()
    }

    @IBAction func txtStudentPasswordPrimaryAction(_ sender: Any) {
        if !captchaEnabled && btnLogin.isEnabled {
            self.btnLoginAction(btnLogin)
        }

        if captchaEnabled {
            self.txtCaptcha.becomeFirstResponder()
        }
    }

    @IBAction func txtCaptchaPrimaryAction(_ sender: Any) {
        if captchaEnabled && btnLogin.isEnabled {
            self.btnLoginAction(btnLogin)
        }
    }

    @IBAction func txtValueChanged(_ sender: Any) {
        autoEnableLoginButton()
    }

    @IBAction func btnFetchCaptchaAction(_ sender: Any) {
        fetchCaptcha()
    }

    @IBAction func btnLoginAction(_ sender: Any) {
        setBusyState(true)

        SchoolSystemModels.submitAuthInfo(installation_id: SAGlobal.installation_id, session_id: self.temp_session_id, student_login: txtStudentLogin.text!, student_password: txtStudentPassword.text!, captcha: txtCaptcha.text) { (success, session_id, message) in
            self.setBusyState(false)

            if success {
                // Set session_id
                if session_id != nil {
                    SAGlobal.student_session_id = session_id
                } else {
                    SAGlobal.student_session_id = self.temp_session_id
                }

                // Save credentials
                SAUtils.writeLocalKVStore(key: "student_login", val: self.txtStudentLogin.text!)
                SAUtils.writeLocalKVStore(key: "student_password", val: self.txtStudentPassword.text!)
                SAUtils.writeLocalKVStore(key: "student_session_id", val: SAGlobal.student_session_id)

                // Return to home page
                self.navigationController?.popViewController(animated: true)
            } else {
                SAUtils.alert(viewController: self, title: "登录失败 😱", message: message)

                // Re-init auth
                self.authInit()
            }
        }
    }

    func autoEnableLoginButton() {
        if (txtStudentLogin.text!.count > 0 &&
            txtStudentPassword.text!.count > 0) {
            btnLogin.isEnabled = true
        } else {
            btnLogin.isEnabled = false
        }
    }

    func setBusyState(_ busy: Bool) {
        tableView.isUserInteractionEnabled = !busy
        btnLogin.isEnabled = !busy
        txtCaptcha.isEnabled = !busy

        if busy {
            actBusy.startAnimating()
        } else {
            actBusy.stopAnimating()
            autoEnableLoginButton()
        }
    }
}
