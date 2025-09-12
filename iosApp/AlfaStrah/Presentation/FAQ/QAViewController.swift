//
//  QAViewController.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class QAViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var topHorizontalCollectionView: QAHorizontalCollectionView!
    
    enum CategoryType {
        case all
        case popular
        case other
    }

    private var selectedCategoryType = CategoryType.all
    var input: Input!
    var output: Output!

    struct Input {
		let isDemo: Bool
        let questionCategories: (_ completion: @escaping ([QuestionCategory]) -> Void) -> Void
    }

    struct Output {
        let openChat: () -> Void
        let selectGroup: (QuestionGroup) -> Void
        let selectQuestion: (Question) -> Void
    }
        
    private func filterTableView(selectCategories: [QuestionCategory], categoryType: CategoryType) {
        self.selectedCategoryType = categoryType
        questionCategories = selectCategories
        tableView.reloadData()
    }

    private var frequentQuestions: [Question] = []
    private var questionCategories: [QuestionCategory] = [] {
        didSet {
            frequentQuestions = questionCategories.flatMap {
                $0.questionGroupList.flatMap {
                    $0.questionList.filter { $0.isFrequent }
                }
            }
        }
    }
    
    private var numberOfFrequentQuestionSections = 0

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("main_faq_title", comment: "")
        configurateTable()
        updateUI()
    }

    private func updateUI() {
		if !input.isDemo
		{
			addRightButton(title: NSLocalizedString("chat_title", comment: ""), action: output.openChat)
		}

        input.questionCategories { [weak self] categories in
            guard let self = self
            else { return }
            
            self.questionCategories = categories
            self.numberOfFrequentQuestionSections = self.frequentQuestions.isEmpty ? 0 : 1
            self.topHorizontalCollectionView.input = .init(
                thereIsPopularQuestions: !self.frequentQuestions.isEmpty,
                additionalCellTitles: [
                    NSLocalizedString("common_all_button", comment: ""),
                    NSLocalizedString("common_popular", comment: "")
                ],
                filterTable: self.filterTableView
            )
            self.topHorizontalCollectionView.notify.updateQuestionCategories(categories)
        }
    }

    private func configurateTable() {
		tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 102.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(QATableCell.id)
    }
    
    // MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: QAHeader = .fromNib()
        switch selectedCategoryType {
            case .other:
                guard let questionCategoriesItem = questionCategories[safe: section] else {
                    return nil
                }
                headerView.set(title: questionCategoriesItem.title)
            case .all:
                if section == 0 && !frequentQuestions.isEmpty {
                    headerView.set(title: NSLocalizedString("common_popular", comment: ""))
                } else if let questionCategoriesItem = questionCategories[safe: section - numberOfFrequentQuestionSections] {
                    headerView.set(title: questionCategoriesItem.title)
                }
            case .popular:
                headerView.set(title: NSLocalizedString("common_popular", comment: ""))
        }
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedCategoryType {
            case .other:
                return questionCategories.count
            case .all:
                return questionCategories.count + numberOfFrequentQuestionSections
            case .popular:
                return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedCategoryType {
            case .other:
                guard let questionCategoriesItem = questionCategories[safe: section] else {
                    return 0
                }
                return questionCategoriesItem.questionGroupList.count
            case .all:
                if section == 0 && !frequentQuestions.isEmpty {
                    return frequentQuestions.count
                } else {
                    guard let questionCategoriesItem = questionCategories[safe: section - numberOfFrequentQuestionSections] else {
                        return 0
                    }
                    return questionCategoriesItem.questionGroupList.count
                }
            case .popular:
                return frequentQuestions.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(QATableCell.id)
        switch selectedCategoryType {
            case .other:
                guard let questionCategoriesItem = questionCategories[safe: indexPath.section],
                      let questionGroupListItem = questionCategoriesItem.questionGroupList[safe: indexPath.row]
                else {
                    return cell
                }
                cell.set(title: questionGroupListItem.title)
            case .all:
                if indexPath.section == 0 && !frequentQuestions.isEmpty {
                    guard let frequentQuestionsItem = frequentQuestions[safe: indexPath.row]
                    else {
                        return cell
                    }
                    cell.set(
                        title: frequentQuestionsItem.questionText
                    )
                } else {
                    guard let questionCategoriesItem = questionCategories[safe: indexPath.section - numberOfFrequentQuestionSections],
                          let questionGroupListItem = questionCategoriesItem.questionGroupList[safe: indexPath.row]
                    else {
                        return cell
                    }
                    cell.set(
                        title: questionGroupListItem.title
                    )
                }
            case .popular:
                guard let frequentQuestionsItem = frequentQuestions[safe: indexPath.row]
                else {
                    return cell
                }
                cell.set(
                    title: frequentQuestionsItem.questionText
                )
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch selectedCategoryType {
            case .other:
                if let questionCategoriesItem = questionCategories[safe: indexPath.section],
                   let questionGroupListItem = questionCategoriesItem.questionGroupList[safe: indexPath.row] {
                    output.selectGroup(questionGroupListItem)
                }
            case .all, .popular:
                if indexPath.section == 0 && !frequentQuestions.isEmpty {
                    guard let question = frequentQuestions[safe: indexPath.row] else {
                        return
                    }
                    output.selectQuestion(question)
                } else if let questionCategoriesItem = questionCategories[safe: indexPath.section - numberOfFrequentQuestionSections],
                          let questionGroupListItem = questionCategoriesItem.questionGroupList[safe: indexPath.row] {
                    output.selectGroup(questionGroupListItem)
                }
        }
        
    }
}
