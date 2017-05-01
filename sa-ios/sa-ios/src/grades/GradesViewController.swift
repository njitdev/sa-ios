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

class GradesViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblGrades: UITableView!

    var data_grades: [GradeItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tblGrades.dataSource = self
        tblGrades.delegate = self
        self.tblGrades.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_grades.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradesTableCell", for: indexPath) as! GradeItemTableCell

        // Get GradeItem
        let g = data_grades[indexPath.row]

        var subtitle = ""
        if let v = g.course_isrequired { subtitle.append(v) }
        if let v = g.course_category   { subtitle.append(", " + v) }
        if let v = g.exam_type         { subtitle.append(", " + v) }

        cell.lblCourseName.text = g.course_name
        cell.lblSubtitle.text = subtitle
        cell.lblCredits.text = g.credits + " 学分"
        cell.lblScore.text = g.score

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
