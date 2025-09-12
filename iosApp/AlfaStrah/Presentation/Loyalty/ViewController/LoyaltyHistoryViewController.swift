//
//  LoyaltyHistoryViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/26/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class LoyaltyHistoryViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    private enum Constants {
        static let defaultOffset = 20
    }

    struct Input {
        let loyaltyOperations: (
            _ count: Int,
            _ offset: Int,
            _ completion: @escaping (Result<[LoyaltyOperation], AlfastrahError>) -> Void
        ) -> Void
    }

    var input: Input!

    private let tableView: UITableView = .init()
    private var canLoadMore: Bool = false
    private var isLoading: Bool = false {
        didSet {
            isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        }
    }

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var operations: [LoyaltyOperation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("alfa_points_details", comment: "")
        view.addSubview(tableView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: tableView, in: view))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
        tableView.registerReusableCell(LoyaltyHistoryCell.id)
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        addZeroView()
        zeroView?.update(viewModel: .init(kind: .loading))
        loadData()
    }

    private func loadData() {
        guard !isLoading else { return }

        isLoading = true
        input.loyaltyOperations(Constants.defaultOffset, operations.count) { [weak self] result in
            guard let self = self else { return }

            self.isLoading = false
            self.hideZeroView()
            switch result {
                case .success(let operations):
                    self.operations += operations
                    self.canLoadMore = operations.count == Constants.defaultOffset
                    guard !operations.isEmpty else {
                        self.showZeroView()
                        self.zeroView?.update(viewModel: .init(kind: .emptyList))
                        return
                    }

                    self.tableView.reloadData()
                case .failure(let error):
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.loadData() }))
                    )
                    self.showZeroView()
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        operations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(LoyaltyHistoryCell.id)
        cell.selectionStyle = .none
        cell.configure(loyaltyOperation: operations[indexPath.row])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isBottom = scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height
        guard isBottom && canLoadMore else { return }

        loadData()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}
