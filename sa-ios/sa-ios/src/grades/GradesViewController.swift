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

class GradesViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblGrades: UITableView!
    @IBOutlet weak var lblGPA: UILabel!
    @IBOutlet weak var lblPassed: UILabel!

    public var data_grades: [GradeItem] = []
    public var data_grades_filtered: [GradeItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google Analytics
        self.screenName = "GradesViewController"

        self.tblGrades.dataSource = self
        self.tblGrades.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
    }

    private func loadData() {
        // Display all data if no filtered data available
        if self.data_grades_filtered.count == 0 {
            self.data_grades_filtered = self.data_grades
        }

        // Count and display pass / total
        var passed = 0
        for g in self.data_grades_filtered {
            if let score = g.score {
                if processScore(score) >= 60 {
                    passed += 1
                }
            }
        }
        self.lblPassed.text = "\(passed) / \(self.data_grades_filtered.count)"

        // Compute and display GPA
        self.lblGPA.text = String(format: "估算绩点: %0.4f", self.computeGPA())

        // Reload table
        self.tblGrades.reloadData()
    }

    private func processScore(_ score: String) -> Int {
        if score == "合格" || score == "及格" {
            return 65
        } else if score == "中等" {
            return 75
        } else if score == "良好" {
            return 85
        } else if score == "优秀" {
            return 95
        }

        if let s = Float(score) {
            return Int(s)
        } else {
            return 0
        }
    }

    private func computeGPA() -> Float {
        var credits_sum: Float = 0
        var weighted_sum: Float = 0

        for g in self.data_grades_filtered {
            if let score = g.score, let credits = g.credits {
                if let credits_f = Float(credits) {
                    let sp = processScore(score)
                    var gp = Float(Int((sp - 50) / 10)) + 0.1 * Float(sp % 10)
                    if (sp < 60) { gp = 0 }
                    weighted_sum += gp * credits_f
                    credits_sum += credits_f
                }
            }
        }
        return weighted_sum / credits_sum
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data_grades_filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradesTableCell", for: indexPath) as! GradeItemTableCell

        // Get GradeItem
        let g = self.data_grades_filtered[indexPath.row]

        var subtitle = ""
        if let v = g.course_isrequired { subtitle.append(v) }
        if let v = g.course_category   { subtitle.append(", " + v) }
        if let v = g.exam_type         { subtitle.append(", " + v) }

        cell.lblCourseName.text = g.course_name
        cell.lblSubtitle.text = subtitle
        cell.lblCredits.text = g.credits
        cell.lblScore.text = g.score

        // Score text color
        var color = UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
        if let score = g.score {
            if processScore(score) < 60 {
                color = UIColor(red:0.94, green:0.33, blue:0.31, alpha:1.0)
            }
        }
        cell.lblScore.textColor = color

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segGradeFilters") {
            if let dest = segue.destination as? GradeFiltersViewController {
                dest.parent_vc = self
                dest.data_grades = self.data_grades
            }
        }
    }
}
