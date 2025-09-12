//
//  ChatSearchResultsViewController.swift
//  AlfaStrah
//
//  Created by vit on 05.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class ChatSearchResultsViewController: ViewController,
                                       UITableViewDelegate,
                                       UITableViewDataSource {
    enum State {
        case emptySearchString
        case emptyResults
        case filled([CascanaSearchResult])
        case loading
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let operationStatusView = OperationStatusView()
    
    struct Output {
        var selectedSearchResult: (CascanaSearchResult) -> Void
    }

    var output: Output!
    
    private lazy var operationStatusViewBottomConstraint: NSLayoutConstraint = {
        return operationStatusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    private lazy var tableViewBottomConstraint: NSLayoutConstraint = {
        return tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    private var searchResults: [CascanaSearchResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Background.backgroundContent
        
        setupTableView()
        setupOperationStatusView()
        
        subscribeForKeyboardNotifications()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.registerReusableCell(ChatSearchResultCell.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
		tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint
        ])
        
        tableView.backgroundColor = .clear
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            operationStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            operationStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            operationStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            operationStatusViewBottomConstraint
        ])
    }
    
    func update(with state: State) {
        switch state {
            case .emptySearchString:
                operationStatusView.isHidden = false
                
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("chat_searchbar_placeholder", comment: ""),
                    description: NSLocalizedString("chat_empty_search_string_description", comment: ""),
                    icon: .Icons.search.resized(newWidth: 54)?.tintedImage(withColor: .Icons.iconAccent).withRenderingMode(.alwaysTemplate)
                ))
                operationStatusView.notify.updateState(state)
                
            case .emptyResults:
                operationStatusView.isHidden = false
                
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("chat_empty_search_results_title", comment: ""),
                    description: NSLocalizedString("chat_empty_search_results_description", comment: ""),
					icon: .Icons.cross.resized(newWidth: 54)?.tintedImage(withColor: .Icons.iconAccent).withRenderingMode(.alwaysTemplate)
                ))
                operationStatusView.notify.updateState(state)
                
            case .filled(let results):
                operationStatusView.isHidden = true
                
                searchResults = results
                
            case .loading:
                operationStatusView.isHidden = false
                
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("common_loading_description", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
                
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResult = searchResults[safe: indexPath.row],
              let attributedString = applySelection(searchResult.highlightedText)
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(ChatSearchResultCell.id)
        
        cell.configure(
            text: attributedString,
            date: searchResult.date
        )
        return cell
    }
    
    private func applySelection(_ text: String) -> NSMutableAttributedString? {
        let attributedString = NSMutableAttributedString()
        let attributedStringWithTags = NSMutableAttributedString(string: text)
        guard let regex = try? NSRegularExpression(pattern: "(?=\\<b\\>).*?(\\<\\/b\\>)", options: [])
        else { return nil }
        let matches = regex.matches(
            in: attributedStringWithTags.string,
            options: [],
            range: NSRange(location: 0, length: attributedStringWithTags.length)
        )
        
        let selectionStyle: [NSAttributedString.Key: Any] = [
			.backgroundColor: UIColor.Background.backgroundAdditional
        ]

		matches.reversed().forEach {
            let replacement = NSAttributedString(
                string: attributedStringWithTags.attributedSubstring(from: $0.range).string.replacingOccurrences(
                    of: "<[^>]+>",
                    with: "",
                    options: .regularExpression,
                    range: nil
                ),
                attributes: selectionStyle
            )
            attributedStringWithTags.replaceCharacters(in: $0.range, with: replacement)
        }
        attributedString.append(attributedStringWithTags)

        return attributedString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedSearchResult = searchResults[safe: indexPath.row]
        else { return }
        
        output.selectedSearchResult(selectedSearchResult)
    }
    
    // MARK: - Keyboard notifications handling
    private func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        operationStatusViewBottomConstraint.constant = 0
        tableViewBottomConstraint.constant = 0
    }
    
    func moveViewWithKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        let constraintConstant = -keyboardHeight
        
        if  operationStatusViewBottomConstraint.constant != constraintConstant {
            operationStatusViewBottomConstraint.constant = constraintConstant
        }
        
        if tableViewBottomConstraint.constant != constraintConstant {
            tableViewBottomConstraint.constant = constraintConstant
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
