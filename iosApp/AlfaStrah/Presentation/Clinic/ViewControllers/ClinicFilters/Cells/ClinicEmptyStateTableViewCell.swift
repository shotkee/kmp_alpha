//
//  ClinicEmptyStateTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 06.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import Legacy

class ClinicEmptyStateTableViewCell: UITableViewCell 
{
	static let id: Reusable<ClinicEmptyStateTableViewCell> = .fromClass()
	
	private let stateView = ZeroView()
	
	// MARK: Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ClinicEmptyStateTableViewCell
{
	func setupUI()
	{
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		contentView.addSubview(stateView)
		stateView.edgesToSuperview(insets: .top(62))
		stateView.isHidden = false
		stateView.update(
			viewModel: .init(
				kind: .custom(
					title: NSLocalizedString("clinic_filter_empty_state_title", comment: ""),
					message: NSLocalizedString("clinic_filter_empty_state_description", comment: ""),
					iconKind: ZeroViewModel.IconKind.custom("search")
				)
			)
		)
	}
}
