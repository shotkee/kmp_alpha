//
//  FileSourceSelectionBottomViewController.swift
//  AlfaStrah
//
//  Created by vit on 01.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class FileSourceSelectionBottomViewController: BaseBottomSheetViewController {
	struct Input {
		let title: String
		let description: String
	}

	struct Output {
		let completion: (_ result: FilePickerSource) -> Void
	}

	var input: Input!
	var output: Output!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setup()
	}

	private func setup() {
		set(style: .empty)
		set(title: input.title)
		set(infoText: input.description)
				
		let cameraButton = createButton(
			title: NSLocalizedString("take_photo", comment: ""),
			icon: .Icons.camera,
			selector: #selector(cameraButtonTap)
		)
		
		let mediaLibraryButton = createButton(
			title: NSLocalizedString("select_from_media_library", comment: ""),
			icon: .Icons.image,
			selector: #selector(mediaLibraryButtonTap)
		)
		
		let selectFileButton = createButton(
			title: NSLocalizedString("select_file", comment: ""),
			icon: .Icons.file,
			selector: #selector(selectFileButtonTap)
		)
		
		let medicalCardButton = createButton(
			title: NSLocalizedString("select_from_medical_card", comment: ""),
			icon: .Icons.medicalCard,
			selector: #selector(medicalCardButtonTap)
		)
		
		set(views: [
			cameraButton,
			separator(),
			mediaLibraryButton,
			separator(),
			selectFileButton,
			separator(),
			medicalCardButton
		])
		
		closeTapHandler = { [weak self] in
			self?.dismiss(animated: true)
		}
	}
	
	private func createButton(
		title: String,
		icon: UIImage,
		selector: Selector
	) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.addTarget(self, action: selector, for: .touchUpInside)
		button.setImage(icon, for: .normal)
		button.tintColor = .Icons.iconAccent
		button.contentHorizontalAlignment = .left
		button.titleEdgeInsets.left = 8
		
		button.titleLabel?.font = Style.Font.headline1
		button.setTitleColor(.Text.textPrimary, for: .normal)
		
		button.height(Constants.buttonHeight)
		
		return button
	}
	
	@objc private func cameraButtonTap() {
		output.completion(.camera)
	}
	
	@objc private func mediaLibraryButtonTap() {
		output.completion(.gallery)
	}
	
	@objc private func selectFileButtonTap() {
		output.completion(.documents)
	}
	
	@objc private func medicalCardButtonTap() {
		output.completion(.medicalCard)
	}
	
	struct Constants {
		static let buttonHeight: CGFloat = 60
	}
}
