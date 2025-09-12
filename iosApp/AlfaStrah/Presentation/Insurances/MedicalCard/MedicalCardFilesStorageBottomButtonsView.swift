//
//  MedicalCardFilesStorageBottomButtonsView.swift
//  AlfaStrah
//
//  Created by vit on 24.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class MedicalCardFilesStorageBottomButtonsView: UIView {
    enum ItemType {
        case selector
        case button
    }
    
    enum Purpose {
        case delete
        case select
    }
    
    struct Item {
        let icon: UIImage?
        let selectedIcon: UIImage?
        let disabledIcon: UIImage?
        let action: ((Bool) -> Void)?
        let type: ItemType
        let purpose: Purpose
        let isEnabled: Bool
    }
    
    private let itemsStackView = UIStackView()
    private let backgroundView = UIView()
    var deleteButton: UIButton = UIButton()
    var selectButton: UIButton = UIButton()
    
    private var items: [Item] = [] {
        didSet {
            for item in items {
                add(
                    menuItem: item,
                    buttonForItem: getButton(
                        item: item
                    )
                )
            }
            setNeedsUpdateConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.layer.cornerRadius = bounds.height / 2
        
        setupShadow()
    }
    
    private func setupUI() {
		addSubview(backgroundView)
		backgroundView.backgroundColor = .Background.backgroundTertiary
        backgroundView.layer.masksToBounds = true
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
                
        itemsStackView.isLayoutMarginsRelativeArrangement = true
        itemsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        itemsStackView.alignment = .fill
        itemsStackView.distribution = .fill
        itemsStackView.axis = .horizontal
        itemsStackView.spacing = 5
        itemsStackView.backgroundColor = .clear
        
        addSubview(itemsStackView)
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: backgroundView, in: self) +
            NSLayoutConstraint.fill(view: self, in: itemsStackView) + [
                itemsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                itemsStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
        )
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
		layer <~ ShadowAppearance.buttonShadow
    }
    
    private func getButton(item: Item) -> UIButton {
        switch item.purpose {
            case .delete:
                return deleteButton
            case .select:
                return selectButton
        }
    }
    
    private func add(menuItem: Item, buttonForItem: UIButton) {
        buttonForItem.setTitle("", for: .normal)
		buttonForItem.setBackgroundColor(.Background.backgroundNegativeTint, forState: .normal)
		buttonForItem.setBackgroundColor(.Background.backgroundAccent, forState: .selected)
		buttonForItem.setBackgroundColor(.Background.backgroundNegativeTint, forState: .disabled)
        buttonForItem.tintColor = .Icons.iconAccent
        buttonForItem.setImage(menuItem.icon, for: .normal)
        buttonForItem.setImage(menuItem.selectedIcon, for: .selected)
		
		let disabledColor = UIColor.Icons.iconAccent.withAlphaComponent(Constants.disabledStateIconOpacity)
		buttonForItem.setImage(menuItem.disabledIcon?.tintedImage(withColor: disabledColor), for: .disabled)
		
        buttonForItem.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        buttonForItem.translatesAutoresizingMaskIntoConstraints = false
        buttonForItem.isEnabled = menuItem.isEnabled

        NSLayoutConstraint.activate([
            buttonForItem.heightAnchor.constraint(equalToConstant: Constants.itemHeight),
            buttonForItem.widthAnchor.constraint(equalTo: buttonForItem.heightAnchor, multiplier: 1)
        ])
        
        buttonForItem.layer.cornerRadius = Constants.itemHeight / 2
        buttonForItem.layer.masksToBounds = true
        
        itemsStackView.addArrangedSubview(buttonForItem)
    }
    
    @objc func handleTap(_ sender: UIButton) {
        if let index = itemsStackView.subviews.firstIndex(where: { ($0 as? UIButton) == sender }) {
            if let item = items[safe: index] {
                switch item.type {
                    case .button:
                        break
                    case .selector:
                        sender.isSelected.toggle()
                }
                
                item.action?(sender.isSelected)
            }
        }
    }
    
    func set(items: [Item]) {
        self.items = items
    }
    
    func resetSelection() {
        for view in itemsStackView.subviews {
            if let button = view as? UIButton {
                button.isSelected = false
            }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		layer <~ ShadowAppearance.buttonShadow
		
		for view in itemsStackView.subviews {
			if let button = view as? UIButton {
				button.setBackgroundColor(.Background.backgroundNegativeTint, forState: .normal)
				button.setBackgroundColor(.Background.backgroundAccent, forState: .selected)
				button.setBackgroundColor(.Background.backgroundNegativeTint, forState: .disabled)
				
				let disabledColor = UIColor.Icons.iconAccent.withAlphaComponent(Constants.disabledStateIconOpacity)
				
				if let image = button.imageView?.image {
					button.setImage(image.tintedImage(withColor: disabledColor), for: .disabled)
				}
			}
		}
	}
    
    struct Constants {
        static let itemHeight: CGFloat = 44
		static let disabledStateIconOpacity = 0.7
    }
}
