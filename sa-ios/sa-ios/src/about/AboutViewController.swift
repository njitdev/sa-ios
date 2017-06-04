//
//  AboutViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 6/4/17.
//
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet weak var lblVersion: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        SAUtils.GAISendScreenView("AboutViewController")

        // Set version label
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lblVersion.text = version
        }

    }

    @IBAction func btnDeveloperkevinlin007Act(_ sender: Any) {
        if let url = URL(string: "https://www.instagram.com/kevinlin22277/") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func btnDeveloperYunzhuAct(_ sender: Any) {
        if let url = URL(string: "https://yunzhu.li") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func btnAppStoreAct(_ sender: Any) {
        if let url = URL(string: "itms://itunes.apple.com/us/app/mygdut/id616723635?mt=8") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
