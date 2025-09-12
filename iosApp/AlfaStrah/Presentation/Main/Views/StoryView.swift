//
//  StoryView.swift
//  AlfaStrah
//
//  Created by Makson on 06.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable line_length file_length
class StoryView: UIView,
                 UICollectionViewDelegate,
                 UICollectionViewDataSource,
                 UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    private let containerView = UIView()
    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.backgroundColor = .clear
        value.delegate = self
        value.dataSource = self
        value.showsHorizontalScrollIndicator = false
        value.showsVerticalScrollIndicator = false
        value.registerReusableCell(StoryCollectionViewCell.id)

        return value
    }()

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value: UICollectionViewFlowLayout = .init()
        value.scrollDirection = .horizontal
        value.minimumInteritemSpacing = 9
        value.minimumLineSpacing = 9
        value.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        value.itemSize = CGSize(width: 102, height: 102)
        return value
    }()
    
    var input: Input!
    
    struct Input {
        let stories: [Story]
    }
    
    var output: Output!
    
    struct Output {
        let select: (Int) -> Void
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        setupContainerView()
        setupCollectionView()
        startLoadingAnimation()
    }
    
    func startLoadingAnimation()
    {
        // need for normal animation cells at start screen https://stackoverflow.com/questions/48136553/tableview-willdisplaycell-called-for-cells-that-are-not-on-the-screen-tableview
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.collectionView.visibleCells.forEach
            {
                if let cell = $0 as? StoryCollectionViewCell
                {
                    cell.updateColorContainerView()
                }
            }
        }
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 102),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    private func setupCollectionView(){
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: collectionView, in: containerView)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        input.stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            StoryCollectionViewCell.id,
            indexPath: indexPath
        )
        
        cell.set(
            story: input.stories[indexPath.item]
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = cell as? StoryCollectionViewCell
        cell?.updateColorContainerView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        output.select(indexPath.item)
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.reloadData()
    }
}
