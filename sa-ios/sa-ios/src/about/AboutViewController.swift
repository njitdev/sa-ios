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

    @IBAction func btnGitHubAct(_ sender: Any) {
        SAUtils.openURL(url: "https://github.com/njitdev/sa-ios")
    }
}
