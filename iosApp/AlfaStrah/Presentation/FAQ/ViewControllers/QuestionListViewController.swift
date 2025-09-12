//
//  QuestionListViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class QuestionListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var askQuestionButton: RoundEdgeButton!
    @IBOutlet private var bottomButtonConstraint: NSLayoutConstraint!
    var input: Input!
    var output: Output!

    struct Input {
        let questions: QuestionGroup
    }
    struct Output {
        let selectQuestion: (Question) -> Void
        let openChat: () -> Void
    }

    private var questions: [Question] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configurateTable()
        configurateButton()
        title = input.questions.title
        questions = input.questions.questionList
        tableView.reloadData()
    }
        
    private func configurateButton() {
        askQuestionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        askQuestionButton.setTitle(NSLocalizedString("insurance_ask_question", comment: ""), for: .normal)
    }

    private func configurateTable() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 102.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(QATableCell.id)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.contentInset.bottom = askQuestionButton.frame.height + bottomButtonConstraint.constant + 10
    }

    // MARK: TableView Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(QATableCell.id)
        cell.set(title: questions[indexPath.row].questionText)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let question = questions[indexPath.row]
        output.selectQuestion(question)
    }
    
    @IBAction func askQuestionTap(_ sender: Any) {
        output.openChat()
    }
}
