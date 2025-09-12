//
//  FilterChipsCollectionView.swift
//  AlfaStrah
//
//  Created by Darya Viter on 20.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class FilterChipsCollectionView: UIView, UICollectionViewDataSource {
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.accessibilityIdentifier = #function
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 15
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.secondaryHeadline2
        label.numberOfLines = 0
        return label
    }()
    private lazy var columnLayout: ColumnCollectionViewFlowLayout = {
        let columnLayout = ColumnCollectionViewFlowLayout()
        columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        columnLayout.minimumInteritemSpacing = 9
        columnLayout.minimumLineSpacing = 9
        columnLayout.scrollDirection = .vertical
        return columnLayout
    }()
    private lazy var lineLayout: UICollectionViewFlowLayout = {
        let lineLayout = UICollectionViewFlowLayout()
        lineLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        lineLayout.minimumInteritemSpacing = 9
        lineLayout.scrollDirection = .horizontal
        return lineLayout
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: columnLayout)
        collectionView.registerReusableCell(OfficeServiceCollectionViewCell.id)
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.scrollIndicatorInsets = .zero
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()

    private lazy var collectionViewHeightConstraint: NSLayoutConstraint = {
        collectionView.heightAnchor.constraint(equalToConstant: 108)
    }()

    private var content: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)] = []
    private var chipTapHandler: (OfficesFilter.OfficeFilterType) -> Void = { _ in }

    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            collectionView.collectionViewLayout = scrollDirection == .horizontal ? lineLayout : columnLayout
            collectionView.bounces = true
            collectionView.contentInset.left = scrollDirection == .horizontal ? 12 : 0
            collectionView.contentInset.right = scrollDirection == .horizontal ? 8 : 0
            collectionView.isScrollEnabled = scrollDirection == .horizontal ? true : false
            collectionViewHeightConstraint.isActive = scrollDirection != .horizontal
        }
    }

    // MARK: Lifecycle

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }

    // MARK: Builders

    private func commonSetup() {
        subviews.forEach { $0.removeFromSuperview() }
        containerStackView.subviews.forEach { $0.removeFromSuperview() }

        addSubview(containerStackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: containerStackView, in: self))

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint.isActive = true
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(collectionView)
    }

    func setup(
        with title: String,
        content: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)],
        chipTapHandler: @escaping (OfficesFilter.OfficeFilterType) -> Void
    ) {
        titleLabel.isHidden = title.isEmpty
        titleLabel.text = title
        self.content = content
        self.chipTapHandler = chipTapHandler

        collectionView.reloadData()
    }

    func reloadData(with content: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)]) {
        self.content = content
        collectionView.reloadData()
    }

    func updateContent(with content: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)]) {
        self.content = content

        collectionView.visibleCells.forEach {
            if let cell = $0 as? OfficeServiceCollectionViewCell, let idx = cell.currentModelIndex {
                let service = content[idx]
                configire(cell, with: service.filter, isSelected: service.isSelected)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        content.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let service = content[indexPath.row]
        let cell = collectionView.dequeueReusableCell(OfficeServiceCollectionViewCell.id, indexPath: indexPath)
        configire(cell, with: service.filter, isSelected: service.isSelected)
        cell.currentModelIndex = indexPath.row
        return cell
    }

    private func configire(_ cell: OfficeServiceCollectionViewCell, with filter: OfficesFilter.OfficeFilterType, isSelected: Bool) {
        cell.configure(
            with: filter.filterName,
            isSelected: isSelected,
            tapHandler: { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let indexPath = self?.collectionView.indexPath(for: cell) {
                        self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    }
                }
                self?.chipTapHandler(filter)
            }
        )
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        collectionView.reloadData()
    }
}
