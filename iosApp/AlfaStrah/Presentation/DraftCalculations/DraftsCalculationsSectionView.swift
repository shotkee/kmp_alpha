//
//  DraftCalculationSection.swift
//  AlfaStrah
//
//  Created by mac on 24.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DraftsCalculationsSectionView: UIView {
    @IBOutlet private var cardView: CardView!
    @IBOutlet private var calculationLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var costLabel: UILabel!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var roundButton: RoundEdgeButton!
	@IBOutlet private var actionCellButtonContainerView: UIView!
	
	let checkbox = CommonCheckboxButton()
	private let contextMenuButton = UIButton(type: .system)
	
	var tapAction: (() -> Void)?
	
	private var contextMenuHandler: (() -> Void)?
	
	var selectionCallback: (() -> Void)?
	var removeCallback: (() -> Void)?
	
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return dateFormatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
		
		setupContextMenuButton()
		setupCommonCheckboxButton()
    }
    
	func setDraftData(_ draft: DraftsCalculationsData) {
		rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		calculationLabel.text = "\(draft.calculationNumber), \(dateFormatter.string(from: draft.date))"
		titleLabel.text = draft.title
		costLabel.text = draft.price
		
		for field in draft.parameters {
			addSectionInStack(title: field.title, description: field.value)
		}
		
		if let daysUntilDelete = draft.daysUntilDelete {
			let expirationTimeLabel = UILabel()
			expirationTimeLabel <~ Style.Label.accentSubhead
			expirationTimeLabel.text = daysUntilDelete
			rootStackView.addArrangedSubview(expirationTimeLabel)
		}
	}

    private func setup() {
		separatorView.backgroundColor = .Stroke.divider
        
		cardView.contentColor = .Background.backgroundSecondary

		calculationLabel <~ Style.Label.secondarySubhead
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.numberOfLines = 2
        costLabel <~ Style.Label.primaryHeadline1

        roundButton <~ Style.RoundedButton.accentButtonSmall
        roundButton.setTitle(NSLocalizedString("draft_calculate_continue_button", comment: ""), for: .normal)
		roundButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
    }

    private func addSectionInStack(title: String, description: String) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
        
        let titleItem = UILabel()
        titleItem <~ Style.Label.secondarySubhead
        titleItem.textAlignment = .left
        titleItem.text = title
        titleItem.setContentHuggingPriority(.required, for: .horizontal)

        let descriptionItem = UILabel()
        descriptionItem <~ Style.Label.primarySubhead
        descriptionItem.textAlignment = .right
        descriptionItem.text = description
        
        stackView.addArrangedSubview(titleItem)
        stackView.addArrangedSubview(descriptionItem)
        
        rootStackView.addArrangedSubview(stackView)
        rootStackView.setCustomSpacing(15, after: stackView)
    }
	
	private func setupContextMenuButton() {
		contextMenuButton.setImage(UIImage(named: "context-menu-icon-medical-card"), for: .normal)
		contextMenuButton.tintColor = .Icons.iconSecondary
		contextMenuButton.setTitle("", for: .normal)
		contextMenuButton.imageView?.contentMode = .center
		
		contextMenuButton.addTarget(self, action: #selector(contextMenuTap), for: .touchUpInside)
		
		actionCellButtonContainerView.addSubview(contextMenuButton)
		contextMenuButton.edgesToSuperview()
		contextMenuButton.height(24)
		contextMenuButton.heightToWidth(of: contextMenuButton)
	}
	
	private func setupCommonCheckboxButton() {
		actionCellButtonContainerView.addSubview(checkbox)
		checkbox.isUserInteractionEnabled = false
		checkbox.edgesToSuperview()
	}
	
	@objc func contextMenuTap(_ sender: Any) {
		contextMenuHandler?()
	}
	
	@objc func buttonTap() {
		self.tapAction?()
	}
	
	func setSelectionMode(_ enable: Bool) {
		contextMenuButton.isHidden = enable
		checkbox.isHidden = !enable
	}
	
	// MARK: - Context menu
	private let menuResponderView = MenuResponderView()
	
	func addContextMenu() {
		if #available(iOS 14.0, *) {
			add(contextMenu: createContextMenu())
		} else {
			contextMenuHandler = { [weak self] in
				guard let self = self
				else { return }
				
				self.menuResponderView.showContextMenu()
			}
			
			menuResponderView.actions = [
				MenuResponderView.Action(type: .remove) {},
				MenuResponderView.Action(type: .select) {}
			]
		}
	}
	
	@available (iOS 14.0, *)
	private func add(contextMenu: UIMenu?) {
		guard let contextMenu = contextMenu
		else { return }
				
		contextMenuButton.showsMenuAsPrimaryAction = true
		contextMenuButton.menu = contextMenu
	}
	
	@available (iOS 14.0, *)
	private func createContextMenu() -> UIMenu? {
		var menuElements: [UIMenuElement] = []
				
		let selectionAction = UIAction(
			title: NSLocalizedString("common_select", comment: ""),
			image: UIImage(systemName: "checkmark.circle")
		) { _ in
			self.selectionCallback?()
		}
		
		let removeAction = UIAction(
			title: NSLocalizedString("common_delete", comment: ""),
			image: UIImage(systemName: "trash"),
			attributes: .destructive
		) { _ in
			self.removeCallback?()
		}
		
		menuElements.append(contentsOf: [selectionAction, removeAction])
		
		return UIMenu(title: "", children: menuElements)
	}
}
