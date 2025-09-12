//
//  EuroProtocolPhotoPickerView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 01.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolPhotoPickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 15

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.primaryText
        value.textAlignment = .left
        value.numberOfLines = 0

        return value
    }()

    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.backgroundColor = .white

        value.delegate = self
        value.dataSource = self

        value.registerReusableCell(EuroProtocolPhotoPickerCollectionViewCell.id)

        return value
    }()

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value: UICollectionViewFlowLayout = .init()
        value.scrollDirection = .vertical
        value.minimumInteritemSpacing = 0
        value.minimumLineSpacing = 0
        value.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 96, right: 0)

        return value
    }()

    struct Output {
        let enableButton: (Bool) -> Void
        let selected: (_ index: Int) -> Void
        let delete: (_ index: Int) -> Void
    }

    var output: Output!

    private var data: [UIImage?] = []

    var photoCount: Int {
        data.filter { $0 != nil }.count
    }

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addSubview(rootStackView)

        rootStackView.addArrangedSubview(infoLabel)
        rootStackView.addArrangedSubview(collectionView)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.rightAnchor.constraint(equalTo: rightAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }

    private func updateUI() {
        infoLabel.text = String(
            format: NSLocalizedString("insurance_euro_protocol_main_accident_photo_picker_info", comment: ""),
            photoCount,
            data.count
        )
        output.enableButton(data.count == photoCount)
    }

    func set(countElements: Int) {
        guard countElements > 0 else { return }

        data = [UIImage?](repeating: nil, count: countElements)
        collectionView.reloadData()
        updateUI()
    }

    func set(photo: UIImage?, index: Int) {
        guard index < data.count else { return }

        data[index] = photo
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        updateUI()
    }

    // MARK: Collection Data Source & Delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(EuroProtocolPhotoPickerCollectionViewCell.id, indexPath: indexPath)
        cell.set(photo: data[indexPath.item])

        cell.deleteHandler = { [unowned self] in
            data[indexPath.item] = nil
            collectionView.reloadItems(at: [indexPath])
            updateUI()
            output.delete(indexPath.item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard data[indexPath.item] == nil else { return }

        output.selected(indexPath.item)
    }

    // MARK: Collection Delegate Flow Layout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = frame.width / 3
        return CGSize(width: width, height: width)
    }
}
