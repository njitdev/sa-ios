//
//  MessageBoardViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//
//

import UIKit

class MessageBoardViewController: GAITrackedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.screenName = "Message Board List"
    }
}
