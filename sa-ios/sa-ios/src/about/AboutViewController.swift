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

    @IBAction func btnDeveloperFangLiuAct(_ sender: Any) {
        SAUtils.openURL(url: "https://github.com/FelicityRooting")
    }

    @IBAction func btnDeveloperkevinlin007Act(_ sender: Any) {
        SAUtils.openURL(url: "https://www.instagram.com/kevinlin22277/")
    }

    @IBAction func btnDeveloperYunzhuAct(_ sender: Any) {
        SAUtils.openURL(url: "https://yunzhu.li")
    }

    @IBAction func btnAppStoreAct(_ sender: Any) {
        SAUtils.openURL(url: "itms://itunes.apple.com/us/app/mygdut/id616723635?mt=8")
    }
}
