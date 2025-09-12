//
//  AboutInsuranceProductViewController.swift
//  AlfaStrah
//
//  Created by Makson on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class AboutInsuranceProductViewController: ViewController,
                                           UITableViewDelegate,
                                           UITableViewDataSource,
                                           TranslucentNavigationViewControllerDelegate {
    private enum Constants {
        static let activeButtonHeight: CGFloat = 48
    }
    
    func backgroundType() -> TranslucentNavigationController.BackgroundType {
        .clear
    }
    
    private var tableView: UITableView = .init()
    private var actionButton = RoundEdgeButton()
    
    var input: Input!
    var output: Output!
    
    struct Input {
        let insuranceProduct: InsuranceProduct
    }
    
    struct Output {
        let openUrl: (URL) -> Void
        let onAction: (BackendAction) -> Void
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
        setupTableView()
        setupActionButton()
    }
	
	private func updateTableViewContentInset() {
		tableView.contentInset = UIEdgeInsets(
			top: UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0,
			left: 0,
			bottom: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + Constants.activeButtonHeight,
			right: 0
		)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		
		updateTableViewContentInset()
	}
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
		tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(AboutInsuranceProductTableViewCell.id)
        tableView.bounces = true
		updateTableViewContentInset()
        view.addSubview(tableView)

        tableView.edgesToSuperview()
    }
	
	private func updateColors() {
		actionButton.isHidden = false
		guard let buttonContent = input.insuranceProduct.detailedButton
		else {
			actionButton.isHidden = true
			return
		}
		
		actionButton.setTitle(
			buttonContent.action.title,
			for: .normal
		)
		
		let textColor = buttonContent.textColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonContent.textColor)
		let backgroundColor = buttonContent.buttonColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonContent.buttonColor)
		
		if let textColor, let backgroundColor {
			actionButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: textColor,
				backgroundColor: backgroundColor
			)
		} else {
			actionButton <~ Style.RoundedButton.redParameterizedButton
		}
	}
    
    private func setupActionButton() {
		updateColors()

		actionButton.clipsToBounds = true
        actionButton.addTarget(self, action: #selector(onTapActionButton), for: .touchUpInside)

        view.addSubview(actionButton)
        
        actionButton.horizontalToSuperview(insets: .horizontal(18))
        actionButton.bottomToSuperview(offset: -9, usingSafeArea: true)
        actionButton.height(Constants.activeButtonHeight)
    }
    
    @objc func onTapActionButton() {
        guard let action = input.insuranceProduct.detailedButton?.action
        else { return }
        
        output.onAction(action)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(AboutInsuranceProductTableViewCell.id)
        cell.selectionStyle = .none
        cell.configure(
            insuranceProduct: input.insuranceProduct
        )
        
        cell.openUrl = { [weak self] url in
            self?.output.openUrl(url)
        }
        
        return cell
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateColors()
	}
}
