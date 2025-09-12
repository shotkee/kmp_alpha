//
//  MedicalCardFileTableCell.swift
//  AlfaStrah
//
//  Created by vit on 20.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import Lottie
import SDWebImage

class MedicalCardFileTableCell: UITableViewCell {
    enum State {
        case localAndRemote     // file exist on clientside and serverside
        case remote             // file exist on serverside and can be donwloaded
        case uploading          // file was placed on clientside and upload was started or in progress
        case error(String)      // any error was occurred during operations
        case virusCheck         // antivirus was launched on server side
        case downloading        // file download is in progress
    }
    
    struct ErrorInfo {
        static let commonError = NSLocalizedString("medical_card_file_entry_common_error", comment: "")
        static let virusCheckError = NSLocalizedString("medical_card_file_entry_virus_check_error", comment: "")
    }
    
    static let id: Reusable<MedicalCardFileTableCell> = .fromClass()
    
    private let containerView = UIView()
    private let fileContentImageView = UIImageView()
    private let fileContentOverlayView = UIView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private var checkbox = CommonCheckboxButton()
    private let contextMenuButton = UIButton(type: .system)
    private let typeSizeLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusInfoButton = UIButton(type: .system)
    private let stateIndicator = UIImageView()
    
    private let menuResponderView = MenuResponderView()
    
    private var contextMenuHandler: (() -> Void)?
    var statusInfoHandler: (() -> Void)?
    
    private var animationView = createAnimationView()
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.dateFormat = "HH:mm, dd MMMM"
        return dateFormatter
    }()
    
    var selectionModeIsActive: Bool = false {
        didSet {
            contextMenuButton.isHidden = selectionModeIsActive
            checkbox.isHidden = !selectionModeIsActive
        }
    }
    
    var renameCallback: (() -> Void)?
    var removeCallback: (() -> Void)?
    var selectionCallback: (() -> Void)?
    var retryUploadCallback: (() -> Void)?
    var downloadCallback: (() -> Void)?
    var cancelLoadingCallback: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationView.play()
    }
    
    private func setupUI() {
		selectionStyle = .none
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupContainerView()
        setupMenuResponderView()
        setupFileContentImageView()
        setupFileContentOverlayView()
        
        setupContextMenuButton()
        setupCommonCheckboxButton()
        setupStatusInfoButton()
        
        setupContentStackView()
        setupTitleLabel()
        setupTypeSizeLabel()
        setupDateLabel()
        
        setupStateIndicator()
        setupAnimationView()
		
		updateSpinner(with: .Icons.iconAccent)
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
                return .error(ErrorInfo.commonError)
            case .uploading:
                return .uploading
            case .virusCheck:
                return .virusCheck
			case .remote, .retry:
                return .remote
            case .downloading:
                return .downloading
        }
    }
    
    private func setVisibleCheckbox(
        fileEntry: MedicalCardFileEntry
    ) {
		checkbox.isHidden = fileEntry.status == .uploading
			? true
			: !selectionModeIsActive
    }
    
    private func applyCellState(_ state: State) {
		statusInfoButton.setTitleColor(.Text.textSecondary, for: .normal)
        switch state {
            case .localAndRemote:
                dateLabel.isHidden = false
                statusInfoButton.isHidden = true
                fileContentOverlayView.isHidden = true
            case .remote:
                dateLabel.isHidden = false
                statusInfoButton.isHidden = true
                fileContentOverlayView.isHidden = false
                updateStateIndicator(with: .fileCanBeDownloaded)
            case .uploading:
                dateLabel.isHidden = true
                statusInfoButton.isHidden = false
                fileContentOverlayView.isHidden = false
                statusInfoButton.setTitle(NSLocalizedString("medical_card_file_state_uploading", comment: ""), for: .normal)
                updateStateIndicator(with: .progress)
            case .error(let text):
                dateLabel.isHidden = true
                statusInfoButton.isHidden = false
                fileContentOverlayView.isHidden = false
                statusInfoButton.setTitle(text, for: .normal)
				statusInfoButton.setTitleColor(.Text.textAccent, for: .normal)
                updateStateIndicator(with: .error)
            case .virusCheck:
                dateLabel.isHidden = false
                statusInfoButton.isHidden = false
                fileContentOverlayView.isHidden = true
                statusInfoButton.setTitle(NSLocalizedString("medical_card_file_state_antivirus_scanning", comment: ""), for: .normal)
            case .downloading:
                dateLabel.isHidden = false
                statusInfoButton.isHidden = true
                fileContentOverlayView.isHidden = false
                updateStateIndicator(with: .progress)
        }
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
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contextMenuButton.leadingAnchor, constant: -9)
        ])
    }
        
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryText
                
        contentStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupContextMenuButton() {
        contextMenuButton.setImage(UIImage(named: "context-menu-icon-medical-card"), for: .normal)
		contextMenuButton.tintColor = .Icons.iconSecondary
        contextMenuButton.setTitle("", for: .normal)
        contextMenuButton.imageView?.contentMode = .center
        
        contextMenuButton.addTarget(self, action: #selector(contextMenuTap), for: .touchUpInside)
        
        containerView.addSubview(contextMenuButton)
        
        contextMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contextMenuButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            contextMenuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contextMenuButton.heightAnchor.constraint(equalToConstant: 40),
            contextMenuButton.widthAnchor.constraint(equalToConstant: 52)
        ] + NSLayoutConstraint.fill(view: menuResponderView, in: contextMenuButton))
    }
    
    private func setupCommonCheckboxButton() {
        containerView.addSubview(checkbox)
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            checkbox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            checkbox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            checkbox.heightAnchor.constraint(equalToConstant: 20),
            checkbox.widthAnchor.constraint(equalTo: checkbox.heightAnchor)
        ])
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
            stateIndicator.heightAnchor.constraint(equalToConstant: 25),
            stateIndicator.widthAnchor.constraint(equalTo: stateIndicator.heightAnchor),
            stateIndicator.centerXAnchor.constraint(equalTo: fileContentOverlayView.centerXAnchor),
            stateIndicator.centerYAnchor.constraint(equalTo: fileContentOverlayView.centerYAnchor),
        ])
    }
    
    private func updateStateIndicator(with state: IndicatorState) {
        switch state {
            case .error:
                stateIndicator.isHidden = false
                stateIndicator.image = UIImage(named: "error-state-indicator-medical-card")
            case .fileCanBeDownloaded:
                stateIndicator.isHidden = false
                stateIndicator.image = UIImage(named: "download-state-indicator-medical-card")
            case .progress:
                stateIndicator.isHidden = true
                animationView.play()
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
    
    private func setupMenuResponderView() {
        containerView.addSubview(menuResponderView)
        menuResponderView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addContextMenu(fileEntry: MedicalCardFileEntry) {
        if #available(iOS 14.0, *) {
            add(contextMenu: createContextMenu(fileEntry: fileEntry))
        } else {
            contextMenuHandler = { [weak self] in
                guard let self = self
                else { return }
                
                self.menuResponderView.showContextMenu()
            }
            
            menuResponderView.actions = getActions(fileEntry: fileEntry)
        }
    }
    
    private func getActions(fileEntry: MedicalCardFileEntry) -> [MenuResponderView.Action] {
        switch fileEntry.status {
            case .uploading:
                return [
                    MenuResponderView.Action(type: .cancelLoading) {}
                ]
            case .virusCheck:
                return [
                    MenuResponderView.Action(type: .moreAbout) {},
                    MenuResponderView.Action(type: .rename) {},
                    MenuResponderView.Action(type: .remove) {},
                    MenuResponderView.Action(type: .select) {},
                ]
			case .remote, .localAndRemote, .retry:
                return [
                    MenuResponderView.Action(type: .download) {},
                    MenuResponderView.Action(type: .rename) {},
                    MenuResponderView.Action(type: .remove) {},
                    MenuResponderView.Action(type: .select) {},
                ]
            case .error:
                var actions: [MenuResponderView.Action] = [
                    MenuResponderView.Action(type: .moreAbout) {},
                    MenuResponderView.Action(type: .remove) {},
                    MenuResponderView.Action(type: .select) {}
                ]
                if fileEntry.localStorageFilename != nil {
                    actions.append(MenuResponderView.Action(type: .retryUpload) {})
                }
                return actions
            case .downloading:
                return [
                    MenuResponderView.Action(type: .rename) {},
                    MenuResponderView.Action(type: .remove) {},
                    MenuResponderView.Action(type: .select) {}
                ]
        }
    }
    
    enum IndicatorState {
        case error
        case fileCanBeDownloaded
        case progress
    }
    
    @objc private func statusInfoTap() {
        statusInfoHandler?()
    }
    
    @objc func contextMenuTap() {
        contextMenuHandler?()
    }
    
    private func bytesCountFormatted(from bytesCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytesCount)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selectionModeIsActive {
            checkbox.isSelected = selected
        }
    }
            
    @available (iOS 14.0, *)
    private func add(contextMenu: UIMenu?) {
        guard let contextMenu = contextMenu
        else { return }
                
        contextMenuButton.showsMenuAsPrimaryAction = true
        contextMenuButton.menu = contextMenu
    }
    
    @available (iOS 14.0, *)
    private func createContextMenu(fileEntry: MedicalCardFileEntry) -> UIMenu? {
        var menuElements: [UIMenuElement] = []
        
        let retryUploadAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_retry_upload", comment: ""),
            image: UIImage(systemName: "arrow.counterclockwise.circle")
        ) { _ in
            self.retryUploadCallback?()
        }
        
        let renameAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_rename", comment: ""),
            image: UIImage(systemName: "square.and.pencil")
        ) { _ in
            self.renameCallback?()
        }
        
        let selectionAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_select", comment: ""),
            image: UIImage(systemName: "checkmark.circle")
        ) { _ in
            self.selectionCallback?()
        }
        
        let removeAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_remove", comment: ""),
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            self.removeCallback?()
        }
        
        let moreAboutAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_more_about", comment: ""),
            image: UIImage(named: "more-about-context-menu-button")
        ) { _ in
            self.statusInfoHandler?()
        }
        
        let downloadAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_download", comment: ""),
            image: UIImage(systemName: "square.and.arrow.down")
        ) { _ in
            self.downloadCallback?()
        }
        
        let cancelLoadingAction = UIAction(
            title: NSLocalizedString("medical_card_files_context_menu_cancel_loading", comment: ""),
			image: .Icons.cross
				.tintedImage(withColor: .Icons.iconMedium)
				.resized(newWidth: 14)
        ) { _ in
            self.cancelLoadingCallback?()
        }
        
        switch fileEntry.status {
            case .uploading:
                menuElements.append(
                    contentsOf: [
                        cancelLoadingAction
                    ]
                )
            case .virusCheck:
                menuElements.append(
                    contentsOf: [
                        moreAboutAction,
                        renameAction,
                        removeAction,
                        selectionAction,
                    ]
                )
			case .remote, .retry:
                menuElements.append(
                    contentsOf: [
                        downloadAction,
                        renameAction,
                        removeAction,
                        selectionAction,
                    ]
                )
            case .error:
                if fileEntry.localStorageFilename != nil {
                    menuElements.append(retryUploadAction)
                }
                menuElements.append(
                    contentsOf: [
                        moreAboutAction,
                        removeAction,
                        selectionAction,
                    ]
                )
            case .downloading, .localAndRemote:
                menuElements.append(
                    contentsOf: [
                        renameAction,
                        removeAction,
                        selectionAction,
                    ]
                )
        }
        
        return UIMenu(title: "", children: menuElements)
    }
}
