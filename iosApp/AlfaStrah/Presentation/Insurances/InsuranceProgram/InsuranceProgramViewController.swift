//
//  InsuranceProgramViewController.swift
//  AlfaStrah
//
//  Created by mac on 19.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints

class InsuranceProgramViewController: ViewController,
									  UITableViewDelegate,
									  UITableViewDataSource {
    private struct Constants {
        static let downloadPdfButtonHeight: CGFloat = 48
        static let downloadPdfButtonBottomConstraint: CGFloat = 9
    }
    
    struct Input {
        var helpBlocks: [InsuranceProgramHelpBlock]
        var showDownloadPdfButton: Bool
        var pdfURL: URL?
    }
    
    struct Output {
        var pdfLinkTap: (URL) -> Void
        var openHelpBlockContent: (InsuranceProgramHelpBlock) -> Void
    }
    
    var input: Input!
    var output: Output!
    private var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("insurance_program", comment: "")
        setupTableView()
        if input.showDownloadPdfButton {
            setupButton()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(QATableCell.id)

        view.addSubview(tableView)
        tableView.edgesToSuperview()
        if input.showDownloadPdfButton {
            tableView.contentInset.bottom = Constants.downloadPdfButtonBottomConstraint + Constants.downloadPdfButtonHeight + 9
        }
    }
    
    private func setupButton() {
        let button = RoundEdgeButton()
        button.setTitle(NSLocalizedString("insurance_program_download_pdf", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(openPdf), for: .touchUpInside)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        view.addSubview(button)
        button.bottom(to: view.safeAreaLayoutGuide, offset: -Constants.downloadPdfButtonBottomConstraint)
        button.horizontalToSuperview(insets: .horizontal(18))
        button.height(48)
    }
    
    @objc private func openPdf() {
        if let url = input.pdfURL {
            output.pdfLinkTap(url)
        }
    }
    
    // MARK: - Table view configurations
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.helpBlocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(QATableCell.id)
        guard let helpBlock = input.helpBlocks[safe: indexPath.row]
        else {
            return UITableViewCell()
        }
        cell.set(title: helpBlock.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let helpBlock = input.helpBlocks[safe: indexPath.row] {
            output.openHelpBlockContent(helpBlock)
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		tableView.reloadData()
	}
}
