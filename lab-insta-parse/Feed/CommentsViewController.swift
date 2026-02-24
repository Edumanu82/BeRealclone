//
//  CommentsViewController.swift
//  lab-insta-parse
//
//  Created by Eduardo M. Sanchez-Pereyra on 2/23/26.
//

import UIKit
import ParseSwift

class CommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!

    var post: Post!

    private var comments = [Comment]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        queryComments()
    }

    private func queryComments() {
        let query = Comment.query()
            .include("user")
            .where("post" == post)

        query.find { [weak self] result in
            switch result {
            case .success(let comments):
                self?.comments = comments
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func onSendTapped(_ sender: Any) {

        guard let text = commentTextField.text, !text.isEmpty else { return }

        var comment = Comment()
        comment.text = text
        comment.post = post
        comment.user = User.current
        comment.username = User.current?.username

        comment.save { [weak self] result in
            switch result {
            case .success:
                self?.commentTextField.text = ""
                self?.queryComments()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CommentsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let comment = comments[indexPath.row]

        cell.textLabel?.text = comment.username ?? "Unknown"
        cell.detailTextLabel?.text = comment.text

        return cell
    }
}

extension CommentsViewController: UITableViewDelegate { }
