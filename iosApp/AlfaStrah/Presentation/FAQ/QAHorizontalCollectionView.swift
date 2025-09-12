//
//  QAHorizontalCollectionView.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class QAHorizontalCollectionView: UIView,
                         UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {
    struct Input {
        var thereIsPopularQuestions: Bool
        var additionalCellTitles: [String]
        var filterTable: ([QuestionCategory], QAViewController.CategoryType) -> Void
    }
    
    var input: Input! {
        didSet {
            numberOfAdditionalCells = input.additionalCellTitles.count
        }
    }
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // in this case define minimumInteritemSpacing and minimumLineSpacing for avoid ui errors
        // https://stackoverflow.com/questions/42980842/minimuminteritemspacing-is-adding-some-strange-content-at-the-end-of-collection
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 9
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    struct Notify {
        let updateQuestionCategories: ([QuestionCategory]) -> Void
    }

    private var questionCategories: [QuestionCategory] = []
    private var numberOfAdditionalCells = 0
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify: Notify = Notify(
        updateQuestionCategories: { [weak self] categories in
            self?.questionCategories = categories
            self?.collectionView.reloadData()
        }
    )
    
    // MARK: Setup

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupCollectionView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCollectionView()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clear

        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: collectionView, in: self)
        )
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerReusableCell(QAHorizontalCollectionCell.id)
    }
    
    private func selectFirstCellInCollection() {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems,
           selectedIndexPaths.isEmpty {
            collectionView.selectItem(at: .init(row: 0, section: 0), animated: false, scrollPosition: [])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectFirstCellInCollection()
    }

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionCategories.count + numberOfAdditionalCells
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(QAHorizontalCollectionCell.id, indexPath: indexPath)

        if indexPath.row < numberOfAdditionalCells {
            cell.set(title: input.additionalCellTitles[indexPath.row])
        } else {
            cell.set(title: questionCategories[indexPath.row - numberOfAdditionalCells].title)
        }

        return cell
    }
        
    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QAHorizontalCollectionCell
        else { return }
        
        if indexPath.row == 0 {
            input.filterTable(questionCategories, QAViewController.CategoryType.all)
            return
        }
        
        if indexPath.row == 1 && input.thereIsPopularQuestions {
            input.filterTable(questionCategories, QAViewController.CategoryType.popular)
            return
        }
        
        let selectCategory = questionCategories[safe: indexPath.row - numberOfAdditionalCells]
        guard let selectCategory else {
            return
        }

        input.filterTable([selectCategory], QAViewController.CategoryType.other)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let labelTitle: String

        if indexPath.row < numberOfAdditionalCells {
            labelTitle = input.additionalCellTitles[indexPath.row]
        } else {
            labelTitle = questionCategories[indexPath.row - numberOfAdditionalCells].title
        }

        let widthLabel = labelTitle.width(
            withConstrainedHeight: 18,
            font: Style.Font.text
        )

        return CGSize(
            width: widthLabel + 30,
            height: 30
        )
    }
}
