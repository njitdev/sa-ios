//
//  HomeViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = SAConfig.appName
    }

    @IBAction func btnLoginAction(_ sender: UIBarButtonItem) {
        SAUtils.alert(viewController: self, title: "Error", message: "Not implemented")
    }
}
