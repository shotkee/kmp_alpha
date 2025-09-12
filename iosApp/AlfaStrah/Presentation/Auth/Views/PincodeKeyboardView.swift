//
//  PincodeKeyboardView.swift
//  AlfaStrah
//
//  Created by vit on 22.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class PincodeKeyboardView: UIView,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {
    enum PincodeError: Error {
        case notMatch
    }
    
    struct Key: Equatable {
        let id: String
        var isHidden: Bool
        let title: String?
        let font: UIFont?
        var icon: UIImage?
        let action: (() -> Void)?
        
        static func == (lhs: PincodeKeyboardView.Key, rhs: PincodeKeyboardView.Key) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    var showExitButton: Bool = false
    var biometryIsAvailable: Bool = false
    var biometryType: BiometryType? // return wrong type if biometry is not available
    var initialSequence: String?

    var close: (() -> Void)?
    var biometricAuthHandler: (() -> Void)?
    var keysInputCompletion: ((Result<String, PincodeError>) -> Void)?
        
    private var codeString = "" {
        didSet {
            updateMultiFunctionalKey()
        }
    }
    
    private func updateMultiFunctionalKey() {
        guard let index = keys.firstIndex(where: { $0 == multiFunctionalKey })
        else { return }
        
        keys[index].icon = imageForMultiFunctionalKey()
        keys[index].isHidden = codeString.isEmpty && !biometryIsAvailable
        
        // suppose no need to calculate position of return key every time
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    private lazy var multiFunctionalKey = {
        return Key(
            id: UUID().uuidString,
            isHidden: { return !biometryIsAvailable }(),
            title: nil, font: nil,
            icon: {
                return imageForMultiFunctionalKey()
            }(),
            action: { [weak self] in
                guard let self = self
                else { return }
                
                if !self.codeString.isEmpty {
                    self.codeString.removeLast()
                    self.codeView.deselectPins(by: self.codeString.count)
                } else {
                    self.biometricAuthHandler?()
                }
            }
        )
    }()
    
    private func imageForMultiFunctionalKey() -> UIImage {
        if codeString.isEmpty {
            guard let biometryType = biometryType
            else { return UIImage() }
            
            switch biometryType {
                case .none:
                    return UIImage()
                case .touchID:
					return Constants.touchIdKeyImage?.tintedImage(withColor: .Icons.iconPrimary) ?? UIImage()
                case .faceID:
                    return Constants.faceIdKeyImage?.tintedImage(withColor: .Icons.iconPrimary) ?? UIImage()
            }
        } else {
            return Constants.returnKeyImage?.tintedImage(withColor: .Icons.iconPrimary) ?? UIImage()
        }
    }
    
    private lazy var keys: [Key] = {
        func id() -> String {
            return UUID().uuidString
        }
        return [
            Key(id: id(), isHidden: false, title: "1", font: nil, icon: nil, action: {
                self.codeString += "1"
            }),
            Key(id: id(), isHidden: false, title: "2", font: nil, icon: nil, action: {
                self.codeString += "2"
            }),
            Key(id: id(), isHidden: false, title: "3", font: nil, icon: nil, action: {
                self.codeString += "3"
            }),
            Key(id: id(), isHidden: false, title: "4", font: nil, icon: nil, action: {
                self.codeString += "4"
            }),
            Key(id: id(), isHidden: false, title: "5", font: nil, icon: nil, action: {
                self.codeString += "5"
            }),
            Key(id: id(), isHidden: false, title: "6", font: nil, icon: nil, action: {
                self.codeString += "6"
            }),
            Key(id: id(), isHidden: false, title: "7", font: nil, icon: nil, action: {
                self.codeString += "7"
            }),
            Key(id: id(), isHidden: false, title: "8", font: nil, icon: nil, action: {
                self.codeString += "8"
            }),
            Key(id: id(), isHidden: false, title: "9", font: nil, icon: nil, action: {
                self.codeString += "9"
            }),
            Key(
                id: id(),
                isHidden: {
                    return !showExitButton
                }(),
                title: NSLocalizedString("common_quit", comment: ""),
                font: Style.Font.text,
                icon: nil,
                action: {
                    self.close?()
                }
            ),
            Key(id: id(), isHidden: false, title: "0", font: nil, icon: nil, action: {
                self.codeString += "0"
            }),
            multiFunctionalKey
        ]
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value = UICollectionViewFlowLayout()
        value.minimumLineSpacing = Constants.collectionViewItemSpacing
        value.minimumInteritemSpacing = Constants.collectionViewItemSpacing
        return value
    }()
    
    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.delegate = self
        value.dataSource = self
        value.registerReusableCell(PincodeKeyCell.id)
        value.clipsToBounds = false
        value.backgroundColor = .clear
        value.showsHorizontalScrollIndicator = false
        value.showsVerticalScrollIndicator = false
        value.isScrollEnabled = false
        return value
    }()
    
    private let codeView = CodeView()
    
    private lazy var collectionViewHeightConstraint: NSLayoutConstraint = {
        return collectionView.heightAnchor.constraint(equalToConstant: 320)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
	
	var keyboardIsBlocked = false
    
    private func setupUI() {
        backgroundColor = .clear
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(codeView)
        codeView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            codeView.topAnchor.constraint(equalTo: topAnchor),
            codeView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            collectionView.topAnchor.constraint(equalTo: codeView.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: widthAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionViewHeightConstraint
        ])
        
        collectionView.reloadData()
    }
    
    // MARK: - Collection view delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let key = keys[indexPath.row]

        let cell = collectionView.dequeueReusableCell(PincodeKeyCell.id, indexPath: indexPath)
        cell.configure(for: key)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Constants.collectionViewItemWidth, height: Constants.collectionViewItemWidth)
    }
    
    private func updatePinsView() {
        let currentPinsCount = codeString.count
        
        codeView.selectPins(by: currentPinsCount)
        
        if currentPinsCount >= Constants.pinsCount {
            // check equality with reference code
            if let initialSequence = initialSequence {
                if initialSequence == codeString {
                    collectionView.isUserInteractionEnabled = false // block input until animation is completed
                    codeView.perfomAcceptAnimation { [weak self] in
                        guard let self = self
                        else { return }

                        self.keysInputCompletion?(.success(self.codeString))
                        self.collectionView.isUserInteractionEnabled = true
                    }
                } else {
                    collectionView.isUserInteractionEnabled = false
                    codeView.performDeclineAnimation { [weak self] in
                        guard let self = self
                        else { return }

                        self.keysInputCompletion?(.failure(.notMatch))
                        self.collectionView.isUserInteractionEnabled = true
                        self.codeView.resetPins()
                        self.codeString = ""
                        
                    }
                }
            } else { // if no initial sequence to compare
                self.keysInputCompletion?(.success(self.codeString))
                self.codeView.resetPins()
                self.codeString = ""
            }
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = keys[indexPath.row]
		if keyboardIsBlocked && indexPath.item != 9 {
			return
		}
        key.action?()
        updatePinsView()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let key = keys[indexPath.row]
            
        return !key.isHidden
    }
	
    struct Constants {
        static let collectionViewItemSpacing: CGFloat = 32
        static let collectionViewItemWidth: CGFloat = 56
        static let pinsCount = 4
		static let faceIdKeyImage = UIImage(named: "ico-face-id-key")
		static let touchIdKeyImage = UIImage(named: "ico-touch-id-key")
		static let returnKeyImage = UIImage(named: "ico-delete-pincode-key")
    }
}

class PincodeKeyCell: UICollectionViewCell {
    static let id: Reusable<PincodeKeyCell> = .fromClass()
    
    override var isHighlighted: Bool {
        didSet {
            containerView.backgroundColor = isHighlighted
				? .Background.backgroundAdditional
                : .clear
        }
    }
    
    private let numberLabel = UILabel()
    private let iconImageView = UIImageView()
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = containerView.bounds.width / 2
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.masksToBounds = true
        
        numberLabel.font = Style.Font.buttonKeyboard
		numberLabel.textColor = .Text.textPrimary
        
        containerView.addSubview(numberLabel)
        numberLabel.numberOfLines = 1
        numberLabel.textAlignment = .center
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.tintColor = .black
        
        NSLayoutConstraint.activate( NSLayoutConstraint.fill(view: containerView, in: contentView) + [
            numberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(
        for key: PincodeKeyboardView.Key
    ) {
        containerView.isHidden = key.isHidden
        
        if let title = key.title {
            numberLabel.text = title
            iconImageView.isHidden = true
        } else if let icon = key.icon {
            iconImageView.image = icon
            numberLabel.isHidden = true
        }
        
        if let font = key.font {
            numberLabel.font = font
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		let image = iconImageView.image
		
		iconImageView.image = image?.tintedImage(withColor: .Icons.iconPrimary)
	}
}

class CodeView: UIView {
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    private let circlesCodeInputStackView = UIStackView()
    private let activityIndicatorView = ActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(circlesCodeInputStackView)
        
        circlesCodeInputStackView.isLayoutMarginsRelativeArrangement = true
        circlesCodeInputStackView.layoutMargins = .zero
        circlesCodeInputStackView.alignment = .fill
        circlesCodeInputStackView.distribution = .fill
        circlesCodeInputStackView.axis = .horizontal
        circlesCodeInputStackView.spacing = 24
        circlesCodeInputStackView.backgroundColor = .clear
        
        circlesCodeInputStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.isHidden = true
		activityIndicatorView.clearBackgroundColor()
        
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 52),
            activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: circlesCodeInputStackView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: circlesCodeInputStackView.centerYAnchor),
            circlesCodeInputStackView.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            circlesCodeInputStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -90),
            circlesCodeInputStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        addPins()
    }
    
    private func addPins() {
        circlesCodeInputStackView.subviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<Constants.pinsCount {
            circlesCodeInputStackView.addArrangedSubview(createCircleView())
        }
    }
    
    private func createCircleView() -> UIView {
        let circle = UIView()
        
        circle.layer.cornerRadius = Constants.pinWidth / 2
        circle.layer.masksToBounds = true
        circle.backgroundColor = .Icons.iconTertiary
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circle.heightAnchor.constraint(equalToConstant: Constants.pinWidth),
            circle.widthAnchor.constraint(equalTo: circle.heightAnchor)
        ])
        
        return circle
    }
    
    func selectPins(by currentCount: Int) {
        if let view = circlesCodeInputStackView.subviews[safe: currentCount - 1] {
            UIView.animate(withDuration: 0.2, animations: {
				view.backgroundColor = .Icons.iconPrimary
                view.transform = view.transform.scaledBy(x: 1.25, y: 1.25)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    view.transform = view.transform.scaledBy(x: 0.8, y: 0.8)
                }
            }
        }
    }
    
    func deselectPins(by currentCount: Int) {
        for (index, view) in circlesCodeInputStackView.subviews.enumerated() {
            if index >= currentCount {
				view.backgroundColor = .Icons.iconTertiary
            }
        }
    }
    
    func resetPins() {
        circlesCodeInputStackView.subviews.forEach { $0.backgroundColor = .Icons.iconTertiary }
    }
    
    func perfomAcceptAnimation(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let subviews = self?.circlesCodeInputStackView.subviews
            else { return }
            
            for view in subviews {
				view.backgroundColor = .Icons.iconPrimary
                view.transform = view.transform.scaledBy(x: 1.25, y: 1.25)
            }
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let stackView = self?.circlesCodeInputStackView
                else { return }
                
                for view in stackView.subviews {
                    view.transform = view.transform.scaledBy(x: 0.0001, y: 0.0001)
                    view.frame.origin.x = stackView.frame.width / 2
                }
            }) { [weak self] _ in
                completion()
                
                guard let self = self
                else { return }
                
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.animating = true
            }
        }
    }
    
    func performDeclineAnimation(_ completion: @escaping () -> Void) {
        generator.impactOccurred()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let subviews = self?.circlesCodeInputStackView.subviews
            else { return }
            
            for view in subviews {
				view.backgroundColor = .Icons.iconNegative
                view.transform = view.transform.scaledBy(x: 1.25, y: 1.25)
            }
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let subviews = self?.circlesCodeInputStackView.subviews
                else { return }
                
                for view in subviews {
                    view.transform = view.transform.scaledBy(x: 0.8, y: 0.8)
                }
                
            }) { _ in
                completion()
            }
        }
    }
	
    struct Constants {
        static let pinWidth: CGFloat = 16
        static let pinsCount = 4
    }
}
