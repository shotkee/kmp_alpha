//
//  HealthAcademyViewController.swift
//  AlfaStrah
//
//  Created by mac on 26.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class HealthAcademyViewController: ViewController,
                                   UICollectionViewDelegate,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    enum ControllerType {
        case healthAcademyHome
        case subsection
    }
    
    struct Output {
        let tap: (HealthAcademyCard) -> Void
    }
    
    var output: Output!
    
    struct Input {
        var cardGroups: [HealthAcademyCardGroup]
        let type: ControllerType
        let title: String
    }

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundContent

        title = input.title
        setupCollectionView()
    }
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		layout.minimumInteritemSpacing = 12
		return UICollectionView(frame: .zero, collectionViewLayout: layout)
	}()
    
    func setupCollectionView() {
		
		collectionView.backgroundColor = .clear
		
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.registerReusableCell(HealthAcademyCardCell.id)
        collectionView.registerReusableSupplementaryView(
            HealthAcademyHeaderReusableView.id,
            kind: UICollectionView.elementKindSectionHeader
        )
        collectionView.registerReusableCell(HealthAcademyListCell.id)
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		collectionView.reloadData()
	}
        
    private func handleTap(on indexPath: IndexPath) {
        let cardGroup = input.cardGroups[safe: indexPath.section]
        guard let unwrappedCardGroup = cardGroup,
              let card = unwrappedCardGroup.cards[safe: indexPath.item] else {
            return
        }
        
        output.tap(card)
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return input.cardGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return input.cardGroups[safe: section]?.cards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cardGroup = input.cardGroups[safe: indexPath.section]
        guard let unwrappedCardGroup = cardGroup,
              let card = unwrappedCardGroup.cards[safe: indexPath.item] else {
            return collectionView.dequeueReusableCell(HealthAcademyCardCell.id, indexPath: indexPath)
        }

        switch unwrappedCardGroup.type {
            case .tile:
                let cell = collectionView.dequeueReusableCell(HealthAcademyCardCell.id, indexPath: indexPath)
				
                cell.set(
					imageUrl: card.imageThemedURL?.url(for: traitCollection.userInterfaceStyle) ?? card.imageURL,
                    title: card.title
                )

                return cell

            case .list:
                let cell = collectionView.dequeueReusableCell(HealthAcademyListCell.id, indexPath: indexPath)
				
                cell.set(
					imageUrl: card.imageThemedURL?.url(for: traitCollection.userInterfaceStyle) ?? card.imageURL,
                    title: card.title
                )

                return cell
        }
    }
	
    func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                let cell = collectionView.dequeueReusableSupplementaryView(
                    HealthAcademyHeaderReusableView.id,
                    indexPath: indexPath,
                    kind: kind
                )

                cell.setTitle(title: input.cardGroups[indexPath.section].title)
                return cell
				
            default:
                return UICollectionReusableView()
				
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cardGroup = input.cardGroups[safe: indexPath.section]
		
        guard cardGroup != nil
		else { return }
        
		handleTap(on: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
		return section == 0 ? 12 : 15
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        switch input.type {
            case .healthAcademyHome:
                return CGSize(width: collectionView.frame.width, height: 50)
            default:
                return .zero
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let offsetToBackView: CGFloat = 18
		
        if section == 0 {
            return UIEdgeInsets(top: 15, left: offsetToBackView, bottom: 4, right: offsetToBackView)
        }
		
        return UIEdgeInsets(top: 21, left: offsetToBackView, bottom: 28, right: offsetToBackView)
    }
}
