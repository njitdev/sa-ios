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

    func enableControls(enabled: Bool) {
        btnSend.isEnabled = enabled
        txtUserName.isEnabled = enabled
        txtUserContact.isEnabled = enabled
        txtText.isEditable = enabled

        // Dim screen
        if enabled {
            self.tableView.alpha = 1
        } else {
            self.tableView.alpha = 0.8
        }
    }

    @IBAction func btnSentAction(_ sender: Any) {
        if (txtUserName.text!.characters.count <= 0 ||
            txtText.text.characters.count <= 0) {
            SAUtils.alert(viewController: self, title: "新留言", message: "昵称和留言是必填内容");
            return;
        }

        // Disable user interaction
        self.enableControls(enabled: false)

        // Construct Post object
        let post = MessageBoardPost(user_name: txtUserName.text!, text: txtText.text)

        // Set optional fields
        post.installation_id = SAGlobal.installation_id
        post.user_contact = txtUserContact.text

        // Send request
        MessageBoardModels.submitPost(post: post, user_student_id: nil) { (success) in
            // Enable user interaction
            self.enableControls(enabled: true)

            if (success) {
                // Return to list view (and refresh)
                self.navigationController?.popViewController(animated: true);
            } else {
                SAUtils.alert(viewController: self, title: "网络错误", message: "留言发送失败");
            }
        }
    }
}
