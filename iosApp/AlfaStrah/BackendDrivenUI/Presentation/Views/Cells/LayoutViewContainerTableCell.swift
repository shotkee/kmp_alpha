//
//  LayoutViewContainerTableCell.swift
//  AlfaStrah
//
//  Created by vit on 23.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class LayoutViewContainerTableCell: UITableViewCell {
		static let id: Reusable<LayoutViewContainerTableCell> = .fromClass()
		
		override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			
			selectionStyle = .none
			
			clearStyle()
		}
		
		func set(
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			selector: WidgetDTO,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			let view = ViewBuilder.constructWidgetView(
				for: selector,
				horizontalLayoutOneSideContentInset: horizontalLayoutOneSideContentInset,
				handleEvent: handleEvent
			)
			
			contentView.addSubview(view)
			view.edgesToSuperview()
		}
		
		override func prepareForReuse() {
			super.prepareForReuse()
			
			contentView.subviews.forEach({ $0.removeFromSuperview() })
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}
