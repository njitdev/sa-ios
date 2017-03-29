//
//  MessageBoardViewController.swift
//  sa-ios
//
//  Created by Yunzhu Li on 3/10/17.
//

import UIKit

class MessageBoardViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblPosts: UITableView!

    // UI
    let cellReuseIdentifier = "MessageBoardListCell"
    let sampleCell = MessageBoardListCell()

    // Data
    var posts: [MessageBoardPost] = []
    var pageSize = 30
    var nextPage = 0
    var allPostsFetched = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableView requires registering custom cells, however it only works when not registered..
        // tblPosts.register(MessageBoardListCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // Set this class as the event delegate and datasource of the UITableview
        tblPosts.delegate = self
        tblPosts.dataSource = self

        // Add pull-to-refresh
        let tblPostsRefreshControl = UIRefreshControl()
        tblPostsRefreshControl.addTarget(self, action: #selector(tblPostsRefresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tblPosts.refreshControl = tblPostsRefreshControl
        } else {
            tblPosts.backgroundView = tblPostsRefreshControl
        }

        // Fetch first page
        tblPostsRefreshControl.beginRefreshing()
        fetchNextPage(refreshControl: tblPostsRefreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.screenName = "Message Board List"
    }

    func tblPostsRefresh(_ refreshControl: UIRefreshControl) {
        nextPage = 0
        fetchNextPage(refreshControl: refreshControl)
    }

    func fetchNextPage(refreshControl: UIRefreshControl?) {
        // Fetch messages via model on screen load
        MessageBoardModels.fetchPosts(page: nextPage) { (posts) in
            // End pull-to-refresh
            refreshControl?.endRefreshing()

            if (posts == nil) {
                // TODO: Prompt for errors
                SAUIUtils.alert(viewController: self, title: "", message: "数据获取失败")

                // Do not update local state
                return
            }

            // Clear local array if first page
            if (self.nextPage == 0) {
                self.allPostsFetched = false
                self.posts = []
            }

            // Detect last page
            if (posts!.count < self.pageSize) {
                self.allPostsFetched = true
            } else {
                self.nextPage += 1
            }

            // Append to local array
            self.posts += posts!
            self.tblPosts.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // Sigle-section table
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows = number of posts + last cell
        return posts.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < posts.count) {
            // Calculate cell height by content
            let textHeight = posts[indexPath.row].text.heightWithConstrainedWidth(width: self.view.frame.width - 30, font: UIFont.systemFont(ofSize: 14))
            return textHeight + 70 - 19 + 1
        } else {
            // Default height for last cell
            return 70
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch reusable cell or allocate a new cell
        let cell = tblPosts.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MessageBoardListCell

        if (indexPath.row < posts.count) {
            // Normal cell, assign values
            cell.lblBackgroundText.isHidden = true
            cell.lblNickname.text = posts[indexPath.row].user_name
            cell.lblText.text = posts[indexPath.row].text
        } else {
            // Last cell, load next page
            cell.lblNickname.text = ""
            cell.lblText.text = ""

            if (allPostsFetched) {
                cell.lblBackgroundText.text = "已加载所有留言"
            } else {
                cell.lblBackgroundText.text = "加载中..."
                if (nextPage > 0) {
                    fetchNextPage(refreshControl: nil)
                }
            }
            cell.lblBackgroundText.isHidden = false
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
