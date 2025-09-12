//
//  PagesProgressBarView.swift
//  AlfaStrah
//
//  Created by vit on 27.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class PagesProgressBarView: UIView {
    @IBOutlet private var progressStackView: UIStackView!
    @IBOutlet private var progressDescriptionLabel: UILabel!
        
    private var itemsCountForLayout: Int = 0
    private var maxLayoutItemsCount: Int = 0
    private var itemsCount: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }
    
    private func commonSetup() {
        addSelfAsSubviewFromNib()
        setupUI()
    }
    
    private func setupUI() {
        progressStackView.spacing = Constants.itemsSpacing
        progressDescriptionLabel <~ Style.Label.secondaryCaption1
    }
    
    func buildItems(count: Int) {
        self.itemsCount = count
        
        progressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let maxItemsCount = calcMaxLayoutItemsCount()
                
        maxLayoutItemsCount = min(itemsCount, maxItemsCount)
        
        for _ in 1...maxLayoutItemsCount {
            let itemView = UIView()
            
			itemView.layer.cornerRadius = progressStackView.bounds.height * 0.5
            itemView.layer.masksToBounds = true
            
            progressStackView.addArrangedSubview(itemView)
        }
    }
    
    func setIndex(_ currentItemIndex: Int) {
        let currentItemIndex = min(currentItemIndex, itemsCount) + 1
        
        let currentItemPositionForLayout = {
            if currentItemIndex == itemsCount {
                return itemsCount <= maxLayoutItemsCount ? itemsCount : maxLayoutItemsCount
            } else if itemsCount > maxLayoutItemsCount {
                return currentItemIndex >= maxLayoutItemsCount ? maxLayoutItemsCount - 1 : currentItemIndex
            }
            return currentItemIndex
        }()
                    
        for (index, view) in progressStackView.subviews.enumerated() {
			view.backgroundColor = index < currentItemPositionForLayout ? .Background.backgroundAccent : .Icons.iconSecondary
        }
                
        let format = NSLocalizedString("pages_progress_bar_template", comment: "")
        progressDescriptionLabel.text = String(format: format, currentItemIndex, itemsCount)
    }
    
    private func calcMaxLayoutItemsCount() -> Int {
        return Int((progressStackView.bounds.width + Constants.itemsSpacing) / (Constants.itemsSpacing + Constants.itemMinWidth))
    }
    
    struct Constants {
        static let maxItems = 10
        static let itemsSpacing: CGFloat = 9
        static let itemMinWidth: CGFloat = 4
    }
}
