//
//  MessageBoardViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//

import UIKit

class MessageBoardViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblPosts: UITableView!

    let cellReuseIdentifier = "MessageBoardListCell"
    let sampleCell = MessageBoardListCell();

    // Data
    var posts: [MessageBoardPost] = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableView requires registering custom cells, however it only works when not registered..
        // tblPosts.register(MessageBoardListCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // Set this class as the event delegate and datasource of the UITableview
        tblPosts.delegate = self
        tblPosts.dataSource = self

        // Pull-to-refresh
        let tblPostsRefreshControl = UIRefreshControl()
        tblPostsRefreshControl.addTarget(self, action: #selector(tblPostsRefresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tblPosts.refreshControl = tblPostsRefreshControl
        } else {
            tblPosts.backgroundView = tblPostsRefreshControl
        }

        tblPostsRefreshControl.beginRefreshing();
        fetchPosts(refreshControl: tblPostsRefreshControl);
    }

    override func viewWillAppear(_ animated: Bool) {
        self.screenName = "Message Board List"
    }

    func fetchPosts(refreshControl: UIRefreshControl?) {
        // Fetch messages via model on screen load
        MessageBoardModels.fetchPosts(page: 0) { (posts) in
            if (posts == nil) {
                // TODO: Prompt for errors

                // Do not update local state
                return;
            }

            self.posts = posts!;
            self.tblPosts.reloadData();

            // End pull-to-refresh
            refreshControl?.endRefreshing();
        }
    }

    func tblPostsRefresh(_ refreshControl: UIRefreshControl) {
        fetchPosts(refreshControl: refreshControl)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // Sigle-section table
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows = number of posts + last cell
        return posts.count + 1;
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < posts.count) {
            // Calculate cell height by content
            let textHeight = posts[indexPath.row].text.heightWithConstrainedWidth(width: self.view.frame.width - 30, font: UIFont.systemFont(ofSize: 14));
            return textHeight + 70 - 19;
        } else {
            // Default height for last cell
            return 70;
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch reusable cell or allocate a new cell
        let cell = tblPosts.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MessageBoardListCell

        if (indexPath.row < posts.count) {
            // Normal cell, assign values
            cell.lblLastCell.isHidden = true;
            cell.lblNickname.text = posts[indexPath.row].user_name
            cell.lblText.text = posts[indexPath.row].text
        } else {
            // Last cell, display static text
            cell.lblNickname.text = "";
            cell.lblText.text = "";
            cell.lblLastCell.isHidden = false;
        }

        return cell;
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}
