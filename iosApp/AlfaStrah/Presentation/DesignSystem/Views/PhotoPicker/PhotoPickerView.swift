//
//  PhotoPickerView.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 04.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//
import UIKit

class PhotoPickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private enum Constants {
        static let bigCardSide: CGFloat = 135
        static let smallCardWidth: CGFloat = 107
        static let smallCardHeight: CGFloat = 96
        static let expandedTouchInsets = UIEdgeInsets(top: -12, left: 0, bottom: 0, right: -12)
        static let interCardSpacing: CGFloat = 9
        static let stackSpacing: CGFloat = 9
        static let collectionViewContentOverlay: CGFloat = 6
    }

    enum PhotoCardType {
        case camera
        case file
        case plus

        var iconImage: UIImage {
            var iconName: String
            switch self {
                case .camera:
                    iconName = "photo"
                case .file:
                    iconName = "document"
                case .plus:
                    iconName = "plusIcon"
            }
            guard let image = UIImage(named: iconName) else {
                fatalError("Image named \"\(iconName)\" not found in resources")
            }

            return image
        }

        var cardSource: [DocumentSource] {
            switch self {
                case .camera:
                    return [ .camera ]
                case .file:
                    return [ .library ]
                case .plus:
                    return [ .camera, .library ]
            }
        }
    }

    enum PhotoCardSize {
        case small
        case big

        var cardSize: CGSize {
            switch self {
                case .big:
                    return CGSize(width: Constants.bigCardSide, height: Constants.bigCardSide)
                case .small:
                    return CGSize(width: Constants.smallCardWidth, height: Constants.smallCardHeight)
            }
        }
    }

    struct Output {
        let selected: (_ index: Int) -> Void
        let delete: (_ index: Int, _ completion: @escaping (Bool) -> Void) -> Void
        let photosPicked: (_ amount: Int) -> Void
    }

    var output: Output!

    private var pickedPhotos: [UIImage?] = [] {
        didSet {
            updateUI()
            updatePhotosPicked()
        }
    }

    private var shouldShowInfoString = false {
        didSet {
            updateUI()
        }
    }

    private (set) var photoCardType: PhotoCardType = .plus
    private var photoCardSize: PhotoCardSize = .small
    private var infoLabel: UILabel = .init()

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = Constants.stackSpacing

        return value
    }()

    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.delegate = self
        value.dataSource = self
        value.registerReusableCell(PhotoCardCollectionViewCell.id)
        value.clipsToBounds = false
        value.backgroundColor = .clear
        value.showsHorizontalScrollIndicator = false

        return value
    }()

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value: UICollectionViewFlowLayout = .init()
        value.minimumLineSpacing = Constants.interCardSpacing
        value.scrollDirection = .horizontal

        return value
    }()

    // MARK: Setup

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        clipsToBounds = true

        addSubview(rootStackView)
        infoLabel.isHidden = true
        infoLabel <~ Style.Label.primaryCaption1
        rootStackView.addArrangedSubview(infoLabel)

        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: Constants.collectionViewContentOverlay).isActive = true
        rootStackView.addArrangedSubview(spacerView)
        rootStackView.setCustomSpacing(0, after: spacerView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self)
        )
        rootStackView.addArrangedSubview(collectionView)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let adjustedRect = bounds.inset(by: Constants.expandedTouchInsets)
        return adjustedRect.contains(point)
    }

    // MARK: Interface

    /// If `shouldShowInfoString` is set `false` beware that
    /// `PhotoPickerView`'s frame is going to be **6 points above** photo card's top line.
    /// Otherwise, the frame is just as expected.
    /// (Reason: on the one there's a 6 pt overlay shadow
    /// and on the other hand `PhotoPickerView` needs its `clipsToBounds` to be `true`
    ///  in order to hide its collection view cells outside of bounds)
    func configure(
        type: PhotoCardType = .camera,
        size: PhotoCardSize = .big,
        numberOfCards: Int,
        shouldShowInfoString: Bool
    ) {
        guard numberOfCards > 0 else { return }

        self.shouldShowInfoString = shouldShowInfoString
        photoCardType = type
        photoCardSize = size

        collectionView.heightAnchor.constraint(
            equalToConstant: photoCardSize.cardSize.height
        ).isActive = true

        pickedPhotos = [UIImage?](repeating: nil, count: numberOfCards)
        collectionView.reloadData()
    }

    func set(_ photo: UIImage?, at index: Int) {
        guard index < pickedPhotos.count else { return }

        pickedPhotos[index] = photo
        collectionView.reloadItems(at: [ IndexPath(item: index, section: 0) ])
    }

    // MARK: Collection view data source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pickedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoCardCollectionViewCell.id, indexPath: indexPath)

        if let pickedPhoto = pickedPhotos[indexPath.item] {
            cell.configure(with: .photo(pickedPhoto))
        } else {
            cell.configure(with: .empty(icon: photoCardType.iconImage))
        }

        cell.deleteHandler = { [unowned self] in
            output.delete(indexPath.item) { success in
                guard success else { return }

                pickedPhotos[indexPath.item] = nil
                collectionView.reloadItems(at: [ IndexPath(item: indexPath.item, section: 0) ])
            }
        }
        return cell
    }

    // MARK: Collection view delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard pickedPhotos[indexPath.item] == nil else { return }

        output.selected(indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        photoCardSize.cardSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        true
    }

    // MARK: Private methods

    private func updateInfoStringText() {
        let photosMade = pickedPhotos.filter { $0 != nil }.count
        infoLabel.text = String(
            format:
                NSLocalizedString("design_system_photo_picker_info_string", comment: ""),
            "\(photosMade)",
            "\(pickedPhotos.count)"
        )
    }

    private func updatePhotosPicked() {
        let photosMade = pickedPhotos.filter { $0 != nil }.count
        output.photosPicked(photosMade)
    }

    private func updateUI() {
        updateInfoStringText()
        infoLabel.isHidden = !shouldShowInfoString
    }
}
