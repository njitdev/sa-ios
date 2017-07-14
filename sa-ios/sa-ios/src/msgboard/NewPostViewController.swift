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
import ObjectMapper

class NewPostViewController: UITableViewController {

    @IBOutlet weak var btnSend: UIBarButtonItem!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtUserContact: UITextField!
    @IBOutlet weak var txtText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        SAUtils.GAISendScreenView("NewPostViewController")
    }

    @IBAction func txtUserNamePrimaryAction(_ sender: Any) {
        txtUserContact.becomeFirstResponder()
    }

    @IBAction func txtUserContactPrimaryAction(_ sender: Any) {
        txtText.becomeFirstResponder()
    }

    @IBAction func btnSendAction(_ sender: Any) {
        if (txtUserName.text!.characters.count <= 0 ||
            txtText.text.characters.count <= 0) {
            SAUtils.alert(viewController: self, title: "新留言 📝", message: "昵称和留言是必填内容");
            return;
        }

        // Disable user interaction
        self.setBusyState(true)

        // Construct Post object
        let post = MessageBoardPost(user_name: txtUserName.text!, text: txtText.text)

        // Set optional fields
        post.installation_id = SAGlobal.installation_id
        post.user_contact = txtUserContact.text

        // Send request
        MessageBoardModels.submitPost(post: post, user_student_id: nil) { (success, message) in
            // Enable user interaction
            self.setBusyState(false)

            if (success) {
                // Return to list view (and refresh)
                self.navigationController?.popViewController(animated: true);
            } else {
                SAUtils.alert(viewController: self, title: "发送失败 😛", message: message);
            }
        }
    }

    // Set UI busy (disable all user interaction)
    func setBusyState(_ busy: Bool) {
        btnSend.isEnabled = !busy
        self.tableView.isUserInteractionEnabled = !busy

        // Dim screen
        self.tableView.alpha = busy ? 0.95 : 1
    }
}
