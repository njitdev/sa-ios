//
//  NewPostViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 4/23/17.
//
//

import UIKit

class NewPostViewController: UITableViewController {

    @IBOutlet weak var btnSend: UIBarButtonItem!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtUserContact: UITextField!
    @IBOutlet weak var txtText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
            SAUtils.alert(viewController: self, title: "新留言", message: "昵称和留言是必填内容");
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
                SAUtils.alert(viewController: self, title: "发送失败", message: message);
            }
        }
    }

    // Set UI busy (disable all user interaction)
    func setBusyState(_ busy: Bool) {
        btnSend.isEnabled = !busy
        self.tableView.isUserInteractionEnabled = !busy

        // Dim screen
        if busy {
            self.tableView.alpha = 0.95
        } else {
            self.tableView.alpha = 1
        }
    }
}
