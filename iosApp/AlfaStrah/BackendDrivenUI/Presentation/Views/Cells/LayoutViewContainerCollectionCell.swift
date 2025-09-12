//
//  TwoColumnLayoutViewContainerCell.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class LayoutViewContainerCollectionCell: UICollectionViewCell {
		static let id: Reusable<LayoutViewContainerCollectionCell> = .fromClass()
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			clearStyle()
		}
		
		func set(
			selector: WidgetDTO,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			let view = ViewBuilder.constructWidgetView(
				for: selector,
				handleEvent: handleEvent
			)
			
			contentView.addSubview(view)
			view.edgesToSuperview()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func prepareForReuse() {
			super.prepareForReuse()
			
			contentView.subviews.forEach({ $0.removeFromSuperview() })
		}
	}
}
