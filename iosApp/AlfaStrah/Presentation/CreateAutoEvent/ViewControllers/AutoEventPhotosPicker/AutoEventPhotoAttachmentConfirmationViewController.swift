//
//  AutoEventPhotoAttachmentConfirmationViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 17.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class AutoEventPhotoAttachmentConfirmationViewController: ViewController {
	
	struct Notify {
		let reload: (_ entry: FilePickerFileEntry?) -> Void
	}
	
	private(set) lazy var notify = Notify(
		reload: { [weak self] entry in
			guard let self,
				  self.isViewLoaded
			else { return }

			if let urlPath = entry?.attachment?.url.path {
				self.imageView.image = UIImage(contentsOfFile: urlPath)
			}
		}
	)
	
	struct Input {
		let lastTakedPhotoEntry: FilePickerFileEntry
	}
	
	var input: Input!
	
	struct Output {
		let retakePhoto: () -> Void
		let savePhoto: () -> Void
	}
	
	var output: Output!
	
	private let imageView = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
	}
	
	private func setupUI() {
		// background
		view.backgroundColor = .Background.backgroundContent
		
		// save button
		let saveButton = RoundEdgeButton()
		saveButton <~ Style.RoundedButton.primaryButtonLarge
		saveButton.setTitle(
			NSLocalizedString("common_save", comment: ""),
			for: .normal
		)
		view.addSubview(saveButton)
		saveButton.bottomToSuperview(
			offset: -15,
			usingSafeArea: true
		)
		saveButton.horizontalToSuperview(insets: .horizontal(15))
		saveButton.height(46)
		
		saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
		
		// retake button
		let retakeButton = RoundEdgeButton()
		retakeButton <~ Style.RoundedButton.redBordered
		retakeButton.setTitle(
			NSLocalizedString("auto_event_photos_picker_retake", comment: ""),
			for: .normal
		)
		view.addSubview(retakeButton)
		retakeButton.bottomToTop(
			of: saveButton,
			offset: -10
		)
		retakeButton.horizontalToSuperview(insets: .horizontal(15))
		retakeButton.height(46)
		
		retakeButton.addTarget(self, action: #selector(retakeButtonTap), for: .touchUpInside)
		
		// subtitle
		let subtitleLabel = UILabel()
		subtitleLabel.text = NSLocalizedString("auto_event_photos_picker_result_subtitle", comment: "")
		subtitleLabel <~ Style.Label.secondarySubhead
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textAlignment = .center
		view.addSubview(subtitleLabel)
		subtitleLabel.bottomToTop(
			of: retakeButton,
			offset: -32
		)
		subtitleLabel.horizontalToSuperview(insets: .horizontal(16))
		subtitleLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// title
		let titleLabel = UILabel()
		titleLabel.text = NSLocalizedString("auto_event_photos_picker_result_title", comment: "")
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		titleLabel.textAlignment = .center
		view.addSubview(titleLabel)
		titleLabel.bottomToTop(
			of: subtitleLabel,
			offset: -6
		)
		titleLabel.horizontalToSuperview(insets: .horizontal(16))
		titleLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// image
		if let urlPath = input.lastTakedPhotoEntry.attachment?.url.path {
			imageView.image = UIImage(contentsOfFile: urlPath)
		}
		imageView.contentMode = .scaleAspectFit
		view.addSubview(imageView)
		imageView.topToSuperview(
			offset: 16,
			usingSafeArea: true
		)
		imageView.bottomToTop(
			of: titleLabel,
			offset: -31
		)
		imageView.horizontalToSuperview(insets: .horizontal(16))
	}
	
	@objc private func saveButtonTap() {
		output.savePhoto()
	}
	
	@objc private func retakeButtonTap() {
		output.retakePhoto()
	}
}
