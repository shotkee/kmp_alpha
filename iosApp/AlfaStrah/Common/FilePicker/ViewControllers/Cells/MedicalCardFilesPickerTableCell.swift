//
//  MedicalCardFilesPickerTableCell.swift
//  AlfaStrah
//
//  Created by vit on 20.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import Lottie
import SDWebImage

class MedicalCardFilesPickerTableCell: UITableViewCell {
	enum State {
		case localAndRemote     					// file exist on clientside and serverside
		case remote             					// file exist on serverside and can be donwloaded
		case uploading          					// file was placed on clientside and upload was started or in progress
		case error(MedicalCardFileEntry.ErrorType?) // any error was occurred during operations
		case virusCheck         					// antivirus was launched on server side
		case downloading        					// file download is in progress
		case retry									// retry operation state
	}
		
	static let id: Reusable<MedicalCardFilesPickerTableCell> = .fromClass()
	
	private let containerView = UIView()
	private let fileContentImageView = UIImageView()
	private let fileContentOverlayView = UIView()
	private let contentStackView = UIStackView()
	private let titleLabel = UILabel()
	private var checkbox = CommonCheckboxButton()
	private let typeSizeLabel = UILabel()
	private let dateLabel = UILabel()
	private let statusInfoButton = UIButton(type: .system)
	private let stateIndicator = UIImageView()
	private let selectionAreaView = UIView()
		
	var statusInfoHandler: (() -> Void)?
	var prepareForReuseCallback: (() -> Void)?
	
	private var animationView = createAnimationView()
	
	private var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = AppLocale.currentLocale
		dateFormatter.dateFormat = "HH:mm, dd MMMM"
		return dateFormatter
	}()
	
	var selectionCallback: (() -> Void)?
	var imageTapCallback: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}
		
	private func setupUI() {
		selectionStyle = .none

		clearStyle()
		
		setupContainerView()
		
		setupFileContentImageView()
		setupFileContentOverlayView()
		
		setupCommonCheckboxButton()
		setupStatusInfoButton()
		
		setupContentStackView()
		setupTitleLabel()
		setupTypeSizeLabel()
		setupDateLabel()
		
		setupStateIndicator()
		setupAnimationView()
		
		updateSpinner(with: .Icons.iconAccent)
		
		setupSelectionAreaView()
	}
	
	func configure(
		searchString: String,
		fileEntry: MedicalCardFileEntry,
		imagePreviewUrl: URL?
	) {
		let attributedFilename = NSMutableAttributedString(string: fileEntry.originalFilename, attributes: [.font: Style.Font.text])

		titleLabel.attributedText = attributedFilename.apply(color: .Text.textAccent, to: searchString)
		
		let fileSizeString = bytesCountFormatted(from: Int64(fileEntry.sizeInBytes))
		
		if let fileExtension = fileEntry.fileExtension {
			typeSizeLabel.text = "\(fileExtension) / \(fileSizeString)"
		} else {
			typeSizeLabel.text = fileSizeString
		}
		
		dateLabel.text = dateFormatter.string(from: fileEntry.creationDate)
		
		applyCellState(Self.state(for: fileEntry))
		titleLabel.numberOfLines = statusInfoButton.isHidden || dateLabel.isHidden ? 2 : 1

		setupFileContentImageView(
			fileEntry: fileEntry,
			url: imagePreviewUrl
		)
		setVisibleCheckbox(
			fileEntry: fileEntry
		)
	}
	
	static func state(for fileEntry: MedicalCardFileEntry) -> State {
		switch fileEntry.status {
			case .localAndRemote:
				return .localAndRemote
			case .error:
				return .error(fileEntry.errorType)
			case .uploading:
				return .uploading
			case .virusCheck:
				return .virusCheck
			case .remote:
				return .remote
			case .downloading:
				return .downloading
			case .retry:
				return .retry
		}
	}
	
	private func setVisibleCheckbox(
		fileEntry: MedicalCardFileEntry
	) {
		checkbox.isHidden = fileEntry.status == .uploading
			|| fileEntry.status == .error
			|| fileEntry.status == .virusCheck
	}
	
	func applyCellState(_ state: State) {
		switch state {
			case .localAndRemote:
				dateLabel.isHidden = false
				statusInfoButton.isHidden = true
				fileContentOverlayView.isHidden = true
				statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
			case .remote:
				dateLabel.isHidden = false
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = false
				updateStateIndicator(with: .fileCanBeDownloaded)
				statusInfoButton.setTitle(NSLocalizedString("chat_files_remote_medical_card_info", comment: ""), for: .normal)
				statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
				
			case .uploading:
				dateLabel.isHidden = true
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = false
				statusInfoButton.setTitle(NSLocalizedString("medical_card_file_state_uploading", comment: ""), for: .normal)
				statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
				updateStateIndicator(with: .progress)
				
			case .error(let errorType):
				dateLabel.isHidden = true
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = false
				
				switch errorType {
					case .common, .typeNotSupported, .none:
						statusInfoButton.setTitle(NSLocalizedString("medical_card_file_entry_common_error", comment: ""), for: .normal)
						
					case .virusOccured:
						statusInfoButton.setTitle(NSLocalizedString("medical_card_file_entry_virus_check_error", comment: ""), for: .normal)
						
				}
				
				statusInfoButton.setTitleColor(.Text.textAccent, for: .normal)
				updateStateIndicator(with: .error)
				
			case .virusCheck:
				dateLabel.isHidden = false
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = true
				statusInfoButton.setTitle(NSLocalizedString("medical_card_file_state_antivirus_scanning", comment: ""), for: .normal)
				statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
				
			case .downloading:
				dateLabel.isHidden = false
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = false
				updateStateIndicator(with: .progress)
				statusInfoButton.setTitle(NSLocalizedString("chat_files_downloading_medical_card_info", comment: ""), for: .normal)
				statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
				
			case .retry:
				dateLabel.isHidden = false
				statusInfoButton.isHidden = false
				fileContentOverlayView.isHidden = false
				statusInfoButton.setTitle(NSLocalizedString("chat_files_retry_info", comment: ""), for: .normal)
				statusInfoButton.setTitleColor(.Text.textAccent, for: .normal)
				updateStateIndicator(with: .retry)
		}
	}
	
	private func setupSelectionAreaView() {
		containerView.addSubview(selectionAreaView)
		
		selectionAreaView.edgesToSuperview(excluding: [.leading, .bottom])
		selectionAreaView.leading(to: contentStackView)
		selectionAreaView.bottomToTop(of: statusInfoButton, offset: -10)
		
		setupSelectionTapGestureRecognizer()
	}
	
	private func setupSelectionTapGestureRecognizer() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
		selectionAreaView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc private func viewTap() {
		selectionCallback?()
	}
	
	private func setupContainerView() {
		containerView.backgroundColor = .Background.backgroundSecondary
		
		let cardView = containerView.embedded(hasShadow: true)
		
		contentView.addSubview(cardView)
		
		cardView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
			cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
		])
	}
		
	private func setupFileContentImageView() {
		containerView.addSubview(fileContentImageView)
		
		fileContentImageView.translatesAutoresizingMaskIntoConstraints = false
		fileContentImageView.isUserInteractionEnabled = true
		
		NSLayoutConstraint.activate([
			fileContentImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
			fileContentImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			fileContentImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
			fileContentImageView.heightAnchor.constraint(equalToConstant: 81),
			fileContentImageView.widthAnchor.constraint(equalToConstant: 74)
		])
		
		fileContentImageView.backgroundColor = .Background.backgroundTertiary
		fileContentImageView.layer.cornerRadius = 3
		fileContentImageView.clipsToBounds = true
		fileContentImageView.contentMode = .center
		
		setupImageTapGestureRecognizer()
	}
	
	private func setupImageTapGestureRecognizer() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
		fileContentImageView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc private func imageTap() {
		imageTapCallback?()
	}
	
	private func setupFileContentImageView(
		fileEntry: MedicalCardFileEntry,
		url: URL?
	){
		guard let fileExtension = fileEntry.fileExtension?.lowercased()
		else {
			fileContentImageView.image = .Icons.unknownFile.tintedImage(withColor: .Icons.iconMedium)
			fileContentImageView.contentMode = .center
			return
		}
		
		if let url = url {
			setPreviewImage(
				url: url,
				placeholderImage: placeholderForImage(
					fileExtension: fileExtension
				)
			)
		} else {
			fileContentImageView.contentMode = .center
			fileContentImageView.image = placeholderForImage(
				fileExtension: fileExtension
			)
		}
	}
	
	private func placeholderForImage(fileExtension: String) -> UIImage? {
		switch fileExtension.lowercased() {
			case "doc":
				return .Icons.docFile.tintedImage(withColor: .Icons.iconMedium)
			case "pdf":
				return .Icons.pdfFile.tintedImage(withColor: .Icons.iconMedium)
			case "dot":
				return .Icons.dotFile.tintedImage(withColor: .Icons.iconMedium)
			case "dotx":
				return .Icons.dotxFile.tintedImage(withColor: .Icons.iconMedium)
			case "docx":
				return .Icons.docxFile.tintedImage(withColor: .Icons.iconMedium)
			case "png":
				return .Icons.pngFile.tintedImage(withColor: .Icons.iconMedium)
			case "jpeg":
				return .Icons.jpegFile.tintedImage(withColor: .Icons.iconMedium)
			case "jpg":
				return .Icons.jpgFile.tintedImage(withColor: .Icons.iconMedium)
			case "tif":
				return .Icons.tifFile.tintedImage(withColor: .Icons.iconMedium)
			case "tiff":
				return .Icons.tiffFile.tintedImage(withColor: .Icons.iconMedium)
			default:
				return .Icons.unknownFile.tintedImage(withColor: .Icons.iconMedium)
		}
	}
	
	private func setPreviewImage(
		url: URL?,
		placeholderImage: UIImage?
	){
		fileContentImageView.contentMode = .center
		fileContentImageView.sd_setImage(
			with: url,
			placeholderImage: placeholderImage,
			completed: { [weak self] _, err, _, _ in
				self?.fileContentImageView.contentMode = err != nil
					? .center
					: .scaleAspectFill
			}
		)
	}
	
	private func setupFileContentOverlayView() {
		fileContentImageView.addSubview(fileContentOverlayView)
		
		fileContentOverlayView.backgroundColor = .Background.backgroundModal.withAlphaComponent(0.6)
		
		fileContentOverlayView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: fileContentOverlayView, in: fileContentImageView))
	}
	
	private func setupContentStackView() {
		containerView.addSubview(contentStackView)
		
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = UIEdgeInsets(top: 12, left: 15, bottom: 9, right: 0)
		contentStackView.alignment = .leading
		contentStackView.distribution = .fill
		contentStackView.axis = .vertical
		contentStackView.spacing = 3
		contentStackView.backgroundColor = .clear

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: fileContentImageView.trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor)
		])
	}
		
	private func setupTitleLabel() {
		titleLabel <~ Style.Label.primaryText
				
		contentStackView.addArrangedSubview(titleLabel)
	}
		
	private func setupCommonCheckboxButton() {
		containerView.addSubview(checkbox)
		
		checkbox.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			checkbox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			checkbox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
			checkbox.heightAnchor.constraint(equalToConstant: 20),
			checkbox.widthAnchor.constraint(equalTo: checkbox.heightAnchor)
		])
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		checkbox.isSelected = selected
	}
		
	private func setupTypeSizeLabel() {
		typeSizeLabel.numberOfLines = 1
		typeSizeLabel <~ Style.Label.secondaryCaption1
		
		contentStackView.addArrangedSubview(typeSizeLabel)
	}
	
	private func setupDateLabel() {
		dateLabel.numberOfLines = 1
		dateLabel <~ Style.Label.secondaryCaption1
		
		contentStackView.addArrangedSubview(dateLabel)
	}
	
	private func setupStatusInfoButton() {
		statusInfoButton.semanticContentAttribute = .forceRightToLeft
		statusInfoButton.titleLabel?.font = Style.Font.caption2
		statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
		statusInfoButton.setImage(.Icons.info.resized(newWidth: 15), for: .normal)
		statusInfoButton.contentEdgeInsets = UIEdgeInsets(
			top: 0,
			left: 0,
			bottom: 12,
			right: 0
		)
		statusInfoButton.addTarget(self, action: #selector(statusInfoTap), for: .touchUpInside)
		statusInfoButton.tintColor = .Icons.iconSecondary
		containerView.addSubview(statusInfoButton)
		statusInfoButton.translatesAutoresizingMaskIntoConstraints = false
		statusInfoButton.titleLabel?.adjustsFontSizeToFitWidth = true
		
		NSLayoutConstraint.activate([
			statusInfoButton.heightAnchor.constraint(equalToConstant: 27),
			statusInfoButton.leadingAnchor.constraint(equalTo: fileContentImageView.trailingAnchor, constant: 12),
			statusInfoButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			statusInfoButton.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -18)
		])
	}
	
	private func setupStateIndicator() {
		fileContentOverlayView.addSubview(stateIndicator)
		
		stateIndicator.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			stateIndicator.heightAnchor.constraint(equalToConstant: 26),
			stateIndicator.widthAnchor.constraint(equalTo: stateIndicator.heightAnchor),
			stateIndicator.centerXAnchor.constraint(equalTo: fileContentOverlayView.centerXAnchor),
			stateIndicator.centerYAnchor.constraint(equalTo: fileContentOverlayView.centerYAnchor),
		])
	}
	
	private func updateStateIndicator(with state: IndicatorState) {
		switch state {
			case .error:
				animationView.stop()
				stateIndicator.isHidden = false
				stateIndicator.image = UIImage(named: "error-state-indicator-medical-card")
				
			case .fileCanBeDownloaded:
				animationView.stop()
				stateIndicator.isHidden = false
				stateIndicator.image = UIImage(named: "download-state-indicator-medical-card")
				
			case .progress:
				stateIndicator.isHidden = true
				animationView.play()
				
			case .retry:
				animationView.stop()
				
				stateIndicator.isHidden = false
				
				let iconWidth: CGFloat = 26
				
				stateIndicator.image = .Icons.redo
					.resized(newWidth: iconWidth, insets: insets(3))?
					.tintedImage(withColor: .Icons.iconContrast)
					.overlay(with: .from(color: .Icons.iconAccent, size: CGSize(width: iconWidth, height: iconWidth), cornerRadius: iconWidth / 2))
				
		}
	}
	
	private static func createAnimationView() -> AnimationView {
		let animation = Animation.named("red-spinning-loader")
		let animationView = AnimationView(animation: animation)
		animationView.backgroundColor = .clear
		animationView.loopMode = .loop
		animationView.contentMode = .scaleAspectFill
		
		let resistantPriority = UILayoutPriority(rawValue: 990)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .horizontal)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .vertical)
		animationView.setContentHuggingPriority(resistantPriority, for: .horizontal)
		animationView.setContentHuggingPriority(resistantPriority, for: .vertical)
		
		animationView.backgroundBehavior = .pauseAndRestore
		
		let keypath = AnimationKeypath(keypath: "Слой-фигура 4.Прямоугольник 1.Заливка 1.Color")
		let colorProvider = ColorValueProvider(UIColor.clear.lottieColorValue)
		animationView.setValueProvider(colorProvider, keypath: keypath)
		
		return animationView
	}
	
	private func updateSpinner(with color: UIColor) {
		let colorProvider = ColorValueProvider(color.lottieColorValue)
		
		let primarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 3.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: primarySpinnerColorKeypath)
		
		let secondarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 2.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: secondarySpinnerColorKeypath)
	}
	
	private func setupAnimationView() {
		fileContentOverlayView.addSubview(animationView)
		
		animationView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			animationView.centerXAnchor.constraint(equalTo: fileContentOverlayView.centerXAnchor),
			animationView.centerYAnchor.constraint(equalTo: fileContentOverlayView.centerYAnchor),
			animationView.heightAnchor.constraint(equalToConstant: 50),
			animationView.widthAnchor.constraint(equalTo: animationView.heightAnchor)
		])
	}
		
	enum IndicatorState {
		case error
		case fileCanBeDownloaded
		case progress
		case retry
	}
	
	@objc private func statusInfoTap() {
		statusInfoHandler?()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		fileContentImageView.sd_cancelCurrentImageLoad()
		
		self.prepareForReuseCallback?()
	}
		
	private func bytesCountFormatted(from bytesCount: Int64) -> String {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useMB, .useKB]
		formatter.countStyle = .file
		return formatter.string(fromByteCount: bytesCount)
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		if selectionAreaView.frame.contains(point)
			|| fileContentImageView.frame.contains(point)
			|| statusInfoButton.frame.contains(point) {
			return super.hitTest(point, with: event)
		}
		
		return nil
	}
}
