//
//  ChatViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SlackTextViewController
import UIKit
import Legacy
import LegacyGallery
import SDWebImage

// swiftlint:disable file_length
typealias MessageActionCallback = (() -> Void)

struct MessageActions {
    let reply: MessageActionCallback?
    let copy: MessageActionCallback?
    let edit: MessageActionCallback?
    let delete: MessageActionCallback?
	let retryOperation: MessageActionCallback?
	let downloadAttachment: MessageActionCallback?
}

private typealias MessageId = String

private extension MessageType {
    var isSupported: Bool {
        switch self {
			case .scoreRequest, .contactInformationRequest, .score, .operatorBusy, .keyboardResponse, .stickerVisitor, .unknown:
                return false
            case .fileFromOperator, .fileFromVisitor, .keyboard, .operatorMessage, .visitorMessage:
                return true
        }
    }
}

final class ChatViewController: SLKTextViewController,
                                DependencyContainerDependency,
                                HttpRequestAuthorizerServiceDependency,
                                UserSessionServiceDependency,
                                ChatServiceDependency,
                                MessageChatBotCellDelegate,
                                GalleryZoomTransitionDelegate,
                                AlertPresenterDependency,
                                DeleteMessageCompletionHandler,
                                SendKeyboardRequestCompletionHandler,
                                AttachmentServiceDependency,
                                LoggerDependency,
                                EditMessageCompletionHandler,
                                UISearchResultsUpdating,
                                UISearchControllerDelegate,
                                UISearchBarDelegate {
    var container: DependencyInjectionContainer?
    var chatService: ChatService!
    var attachmentService: AttachmentService!
    var httpRequestAuthorizer: HttpRequestAuthorizer!
    var userSessionService: UserSessionService!
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?
    
    struct Notify {
        let updateState: (_ state: ChatServiceState) -> Void
        let setTypingIndicatorVisible: (_ isTyping: Bool) -> Void
        let messagesChanged: () -> Void
		let operatorScoreChanged: () -> Void
		let showScoreOperationResult: (Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        updateState: { [weak self] serviceState in
            guard let self,
                  self.isViewLoaded
            else { return }
            
            self.updateServiceState(serviceState)
            self.updateRateButton()
        },
        setTypingIndicatorVisible: { [weak self] isTyping in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.setTypingIndicatorVisible(isTyping)
        },
        messagesChanged: { [weak self] in
            guard let self,
                  self.isViewLoaded
            else { return }
            
            DispatchQueue.main.async { [weak self] in
				guard let self
				else { return }
				
				self.updateData()
             }
            
            self.updateTextInputbarVisibility()
        },
		operatorScoreChanged: {
			self.updateRateOperatorButton()
		},
		showScoreOperationResult: { result in
			let icon: UIImage? = result
				? .Icons.tick.resized(newWidth: 20)?.tintedImage(withColor: .Icons.iconAccent)
				: .Icons.info.resized(newWidth: 20)?.tintedImage(withColor: .Icons.iconAccent)
			
			let title = result 
				? ""
				: NSLocalizedString("chat_rate_failure_banner_title", comment: "")
			
			let description = result
				? NSLocalizedString("chat_rate_success_banner_description", comment: "")
				: NSLocalizedString("chat_rate_failure_banner_description", comment: "")
			
			showStateInfoBanner(
				title: title,
				description: description,
				hasCloseButton: false,
				iconImage: icon,
				titleFont: Style.Font.headline3,
				appearance: .standard
			)
		}
    )
	
	private func updateData() {
		tableView?.reloadData()
		updateRateOperatorButton()
	}
	
	private func updateRateOperatorButton() {
		rateOperatorButtonView.isHidden = (self.chatService.currentOperator?.ratingCanBeGiven() ?? false) == false

		let rateButtonText = (self.chatService.currentOperator?.getRate() ?? 0) == 0
			? NSLocalizedString("chat_rate_top_button_default_title", comment: "")
			: NSLocalizedString("chat_rate_top_button_change_title", comment: "")
		
		rateOperatorButtonView.set(title: rateButtonText)
	}
	
	struct Input {
		let didAppear: () -> Void
	}
	var input: Input!
    
    struct Output {
        let getLastOperatorRating: () -> Int?
        let showRateOperator: (Int?) -> Void
		let attachFile: () -> Void
    }
    var output: Output!
    
    let disposeBag: DisposeBag = DisposeBag()
    
    let operationStatusView = OperationStatusView()
    
    private var previousChatServiceState: ChatServiceState?
    
    private var chatState: ChatState?
    private var canDisplayMoreMessages: Bool = true
    
    private var cellsWithSpinners = [MessageId: KeyboardButtonIndex]()
    
    private lazy var photoSelectionBehavior = DocumentPickerBehavior()
    private var selectedPhotoIndex: Int?
    
    private var rateButton: UIBarButtonItem?
    private var keyboardButton: UIBarButtonItem?
    private var keyboardButtonIsVisible: Bool = false
    
    private var selectedAttachmentCell: MessageBubbleCell? {
        guard let selectedRow = selectedPhotoIndex
		else { return nil }
        
        return tableView?.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? MessageBubbleCell
    }
	
	private var selectedImage: UIImage? = nil
    
    private let scrollToLastMessageButton = ScrollToLastMessageButton()
    private var scrollViewContentOffsetObserver: NSKeyValueObservation?
    
    private let quoteView = TextInputBarQuoteView()
    private var messageBeingRepliedTo: Message?
    
    private var messageBeingDeleted: Message?
    
    private var messageBeingEdited: Message?
    private var hideLoadingIndicator: ((_ completion: (() -> Void)?) -> Void)?
	
	private let rateOperatorButtonView = RateOperatorButtonView()
    
    override func viewDidLoad() {
        // must precede super.viewDidLoad() or else default view will be used
        setupTypingIndicatorView()
        super.viewDidLoad()
        
        title = NSLocalizedString("chat_title", comment: "")
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        view.backgroundColor = .Background.backgroundContent
        
        setupTableView()
        setupSlackTextViewController()
        setupOperationStatusView()
		
		setupRateOperatorButtonView()
    }
    
    private var chatNonFatalErrorsSubscription: Subscription?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatNonFatalErrorsSubscription = chatService.subscribeForNonFatalErrors { error in
            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
        }
                
        // set clip here in appear method becasue SLKTextViewController will modify it before
        leftButton.clipsToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch chatService.serviceState {
            case .disabled, .logout:
                chatService.startNewChatService()
                
            case
                .loading, .demoMode,
                .emptyUserInfo, .fatalError, .accessError,
                .unknownError, .sessionError, .networkError, .started, .chatting:
                break  // these states will be handled by retry button new chat session start
        }
        
        updateServiceState(chatService.serviceState)
        
		updateData()
		
        // sequence updateTextInputbarVisibility and tableView - reloadData is important
        // SLKTextViewController hide input bar only on table reload after set of relevant parameters
        // in viewDidAppear
        updateTextInputbarVisibility()
		
		input.didAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideTextInputKeyboard()
        chatNonFatalErrorsSubscription?.unsubscribe()
    }
    
    // swiftlint:disable function_body_length
    private func updateServiceState(_ state: ChatServiceState) {
        updateOperationStatusView(for: state)
        
        guard previousChatServiceState != state
        else { return }
        
        switch state {
            case .loading:
                updateChatState(.unknown)
                
            case .started, .demoMode:
                break
                
            case .chatting(let chatState):
                if self.chatState != chatState {
                    updateChatState(chatState)
                }
                
            case .disabled, .logout:
                break
                
            case
                .networkError,
                .accessError,
                .fatalError,
                .sessionError,
                .unknownError,
                .emptyUserInfo:
                break
                
        }
        
        previousChatServiceState = state
    }
    // swiftlint:enable function_body_length
	
	private func setupRateOperatorButtonView() {
		view.addSubview(rateOperatorButtonView)
		
		rateOperatorButtonView.leadingToSuperview()
		rateOperatorButtonView.trailingToSuperview()
		rateOperatorButtonView.topToSuperview(usingSafeArea: true)
		rateOperatorButtonView.height(38)
		rateOperatorButtonView.isHidden = true
		
		rateOperatorButtonView.action = {
			let rate: Int? = self.chatService.currentOperator?.getRate()
			
			self.output.showRateOperator(rate)
		}
	}
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }
    
    private func updateOperationStatusView(for state: ChatServiceState) {
        operationStatusView.notify.addCustomViews([])
        operationStatusView.isHidden = true
        
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                tableView?.isHidden = true
                navigationItem.rightBarButtonItems = nil
                
                let state: OperationStatusView.State = .info(.init(
                    title: "",
                    description: NSLocalizedString("chat_loading_description", comment: ""),
                    icon: .Illustrations.chatting
                ))
                operationStatusView.notify.updateState(state)
                hideTextInputKeyboard()
				navigationItem.searchController = nil
				
				rateOperatorButtonView.isHidden = true
                
            case .started:
                navigationItem.rightBarButtonItems = nil
                tableView?.isHidden = true
                hideTextInputKeyboard()
				navigationItem.searchController = nil
                
				rateOperatorButtonView.isHidden = true
				
            case .demoMode:
                navigationItem.rightBarButtonItems = nil
                tableView?.isHidden = true
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .info(.init(
                    title: "",
                    description: NSLocalizedString("common_demo_mode_alert", comment: ""),
                    icon: .Illustrations.chatting
                ))
                operationStatusView.notify.updateState(state)
                hideTextInputKeyboard()
				navigationItem.searchController = nil
				
				rateOperatorButtonView.isHidden = true
                
            case .chatting:
                tableView?.isHidden = false
                operationStatusView.isHidden = true
                
                setupBarSearchButtonItem()
                setupBarKeyboardButtonItem()
                
                if let keyboardButton,
                   navigationItem.rightBarButtonItems != nil,
                   keyboardButtonIsVisible {
                    navigationItem.rightBarButtonItems?.append(keyboardButton)
                }
                
            case .disabled:
                tableView?.isHidden = true
                navigationItem.rightBarButtonItems = nil
                operationStatusView.isHidden = false
                hideTextInputKeyboard()
				navigationItem.searchController = nil
				
				rateOperatorButtonView.isHidden = true
                
            case .logout:
                tableView?.isHidden = true
                navigationItem.rightBarButtonItems = nil
                operationStatusView.isHidden = false
                hideTextInputKeyboard()
				navigationItem.searchController = nil
				
				rateOperatorButtonView.isHidden = true
                
            case
				.networkError,
				.accessError,
				.fatalError,
				.sessionError,
				.unknownError:
                navigationItem.rightBarButtonItems = nil
                operationStatusView.isHidden = false
                tableView?.isHidden = true
				navigationItem.searchController = nil
                
                errorCommonHandler()
                
                hideTextInputKeyboard()
				
				rateOperatorButtonView.isHidden = true
				
            case .emptyUserInfo:
                break
                
        }
    }
    
    private func setupBarSearchButtonItem() {
        let button = UIBarButtonItem(
            image: .Icons.search,
            style: .plain,
            target: self,
            action: #selector(searchButtonTap)
        )
        
        button.tintColor = .Icons.iconAccentThemed
        
        navigationItem.rightBarButtonItems = [button]
    }
    
    @objc func searchButtonTap() {
        createSearchController()
    }
    
    private func errorCommonHandler() {
        let state: OperationStatusView.State = .info(.init(
            title: NSLocalizedString("chat_error_common_title", comment: ""),
            description: NSLocalizedString("chat_error_common_description", comment: ""),
			icon: .Icons.cross.resized(newWidth: 32)?.withRenderingMode(.alwaysTemplate),
            buttonsAlignment: .center
        ))
        
        let buttonContainer = UIView()
        let retryButton = RoundEdgeButton() <~ Style.RoundedButton.oldOutlinedButtonSmall
        buttonContainer.addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryButtonTap), for: .touchUpInside)
        retryButton.setTitle(NSLocalizedString("chat_error_retry_button_title", comment: ""), for: .normal)
        
        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            retryButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            retryButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 52),
            retryButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -52),
            retryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let buttons: [UIView] = [ buttonContainer ]
        
        operationStatusView.notify.updateState(state)
        operationStatusView.notify.addCustomViews(buttons)
    }
    
    @objc func retryButtonTap() {
        chatService.startNewChatService()
    }
    
    private func somethingWentWrongStateHandler() {     // state for future use
        let state: OperationStatusView.State = .info(.init(
            title: NSLocalizedString("chat_error_something_went_wrong_title", comment: ""),
            description: NSLocalizedString("chat_error_something_went_wrong_description", comment: ""),
            icon: UIImage(named: "icon-chat-init-error-state"),
            buttonsAlignment: .center,
            buttonsAxis: .horizontal
        ))
        
        let cardButtons: [UIView] = [
            createCardViewButton(
                title: NSLocalizedString("common_call", comment: ""),
                icon: UIImage(named: "icon-phone-2") ?? UIImage(),
                selector: #selector(phoneCallTap)
            ),
            createCardViewButton(
                title: NSLocalizedString("common_write_email", comment: ""),
                icon: UIImage(named: "icon_letter_24") ?? UIImage(),
                selector: #selector(emailTap)
            )
        ]
        operationStatusView.notify.updateState(state)
        operationStatusView.notify.addCustomViews(cardButtons)
    }
    
    @objc func phoneCallTap() {}
    
    @objc func emailTap() {}
    
    private func createCardViewButton(
        title: String,
        icon: UIImage,
        selector: Selector
    ) -> CardView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .Background.backgroundContent
        
        let cardViewContainer = CardView(contentView: backgroundView)
        cardViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardViewContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 3
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .zero
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        
        backgroundView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentStackView, in: backgroundView, margins: insets(15)))
        
        let imageBackgroundView = UIView()
        contentStackView.addArrangedSubview(imageBackgroundView)
        
        let imageView = UIImageView(image: icon)
        imageBackgroundView.addSubview(imageView)
        
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageBackgroundView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: imageBackgroundView.centerXAnchor)
        ])
        
        let titleLabel = UILabel() <~ Style.Label.primaryText
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.textAlignment = .center
        contentStackView.addArrangedSubview(titleLabel)
        
        let actionButton = UIButton()
        actionButton.addTarget(self, action: selector, for: .touchUpInside)
        
        cardViewContainer.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: actionButton, in: cardViewContainer))
        
        return cardViewContainer
    }
    
    private func updateRateButton() {
        rateButton?.isEnabled = chatService.currentOperator != nil
    }
    
    private func updateChatState(_ state: ChatState) {
        chatState = state
        
        if state == .chatting {
            DispatchQueue.main.async { [weak self] in
				guard let self
				else { return }
				
				self.updateData()
            }
            
            updateTextInputbarVisibility()
        }
    }
    
    private func updateTextInputbarVisibility() {
        isTextInputbarHidden = false
        
        if isTextInputbarHidden,
           messageBeingRepliedTo != nil {
            endReplying()
        }
    }
    
    private func setupBarKeyboardButtonItem() {
        if keyboardButton != nil {
            return
        }
        
        let button = UIBarButtonItem(
            image: UIImage(named: "icon-chat-keyboard-button") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(keyboardButtonTap(_:))
        )
        
        button.tintColor = .Icons.iconAccentThemed
        
        keyboardButton = button
    }
        
    // MARK: - Slack Controller UI
    private func setupSlackTextViewController() {
        // since we can't use constraint for slack view controller ui components
        let leftButtonWidth = 42
        leftButton.setImage(
            UIImage.backgroundImage(
                withColor: .Background.backgroundSecondary,
                size: CGSize(width: leftButtonWidth, height: leftButtonWidth)
            ).roundedImage,
            for: .normal
        )
        leftButton.tintColor = .Background.backgroundSecondary
        
        let leftButtonImageView = UIImageView(image: .Icons.attach)
        leftButtonImageView.tintColor = .Icons.iconMedium
        leftButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.addSubview(leftButtonImageView)
        leftButtonImageView.center(in: leftButton)
        leftButtonImageView.width(20)
        leftButtonImageView.heightToWidth(of: leftButtonImageView)
        
        leftButton.clipsToBounds = false
        leftButton.layer.shadowRadius = 20
        leftButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        leftButton.layer.shadowOpacity = 1
        leftButton.layer.shadowColor = UIColor.Shadow.buttonShadow.cgColor
        
        rightButton.setImage(
            UIImage.Icons.send.tintedImage(withColor: .Icons.iconTertiary),
            for: .normal
        )
        rightButton.tintColor = .Icons.iconAccent
        
        rightButton.setTitle(nil, for: .normal)
        
        setupTextInputbar()
        setupReplyQuoteView()
        setupScrollToLastMessageButton()
    }
    
    private func setupTextInputbar() {
        textInputbar.autoHideRightButton = false
        textInputbar.backgroundColor = .Background.backgroundContent
        textInputbar.textView.backgroundColor = .clear
        textInputbar.textView.layer.borderWidth = 0
        textInputbar.setShadowImage(UIImage.backgroundImage(withColor: .Stroke.divider), forToolbarPosition: .bottom)
        
        textInputbar.textView.placeholder = NSLocalizedString("chat_text_input_placeholder", comment: "")
        textInputbar.textView.placeholderFont = Style.Font.text
        textInputbar.textView.placeholderColor = .Text.textSecondary
        textInputbar.textView.textColor = .Text.textPrimary
        textInputbar.textView.font = Style.Font.text
        textInputbar.contentInset = UIEdgeInsets(
            top: 12,
            left: Style.Margins.default,
            bottom: 30,
            right: Style.Margins.default
        )
        textInputbar.tintColor = .Text.textAccent
        
        textInputbar.contentView.backgroundColor = .clear
        textInputbar.isTranslucent = false
        
        textInputbar.editorTitle.text = nil
        textInputbar.editorLeftButton.setTitle(
            NSLocalizedString("chat_editing_cancel_changes_button", comment: ""),
            for: .normal
        )
        textInputbar.editorRightButton.setTitle(
            NSLocalizedString("chat_editing_save_changes_button", comment: ""),
            for: .normal
        )
        textInputbar.editorLeftButton.titleLabel?.font = Style.Font.text
        textInputbar.editorRightButton.titleLabel?.font = Style.Font.text
    }
    
    private func setupReplyQuoteView() {
        bottomBarView.addSubview(quoteView)
        bottomBarViewHeight = 55.0
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(
            view: quoteView,
            in: bottomBarView
        ))
        quoteView.backgroundColor = .Background.backgroundContent
        quoteView.cancelButtonHandler = { [weak self] in
            self?.endReplying()
            self?.hideTextInputKeyboard()
        }
    }
    
    private func setupTypingIndicatorView() {
        registerClass(forTypingIndicatorView: TypingIndicatorView.self)
    }
    
    private func setTypingIndicatorVisible(_ showTypingIndicator: Bool) {
        typingIndicatorProxyView.isVisible = showTypingIndicator
    }
    
    private func setupScrollToLastMessageButton() {
        view.addSubview(scrollToLastMessageButton)
        
        scrollToLastMessageButton.translatesAutoresizingMaskIntoConstraints = false
        scrollToLastMessageButton.rightAnchor.constraint(
            equalTo: textInputbar.rightAnchor,
            constant: -18
        ).isActive = true
        scrollToLastMessageButton.bottomAnchor.constraint(
            equalTo: textInputbar.topAnchor,
            constant: -10
        ).isActive = true
        
        scrollViewContentOffsetObserver = tableView?.observe(\UITableView.contentOffset, options: .new) { [weak self] tableView, _ in
            self?.updateScrollToLastMessageButton(tableView: tableView)
            MessageBubbleCell.hideFloatingMenuIfNeeded()
        }
        scrollToLastMessageButton.button.addTarget(
            self,
            action: #selector(onScrollToLastMessageButton),
            for: .touchUpInside
        )
    }
    
    private func updateScrollToLastMessageButton(tableView: UITableView) {
        let lastIndexPath = IndexPath(row: 0, section: 0)
        let lastMessageCell = tableView.cellForRow(at: lastIndexPath)
        let lastMessageCellHeight = lastMessageCell?.frame.height ?? 0
        
        let isBottomReached = tableView.contentOffset.y <= lastMessageCellHeight
        scrollToLastMessageButton.isHidden = isBottomReached
    }
    
    @objc private func onScrollToLastMessageButton() {
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        if chatService.messages.isEmpty {
            return
        }
        
        let bottomMessageIndex = IndexPath(row: 0, section: 0)
        tableView?.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
	
	private func imageFromDatasource(at index: Int, completion: @escaping (Result<UIImage?, Error>) -> Void){
		guard let message = chatService.messages[safe: (chatService.messages.count - 1) - index],
			  let attachmentUrl = attachmentUrl(from: message),
			  attachmentUrl.isImageFile
		else { return }
				
		if attachmentUrl.isFileURL,
		   let image = UIImage(contentsOfFile: attachmentUrl.path) {
			completion(.success(image))
			
			return
		}
		
		chatService.cachedImage(for: attachmentUrl, completion: completion)
	}
    
    private func showPhoto(at index: Int) {
        selectedPhotoIndex = index
		
		imageFromDatasource(at: index) { [weak self] result in
			guard let self
			else { return }
			
			switch result {
				case .success(let image):
					if let image {
						self.selectedImage = image
						self.showGallery(with: image)
					}
					
				case .failure:
					break
			}
		}
		
    }
	
	private func showGallery(with image: UIImage) {
		let galleryController = GalleryViewController()
		let mediaItem = GalleryMedia.Image(
			previewImage: nil,
			previewImageLoader: nil,
			fullImage: image,
			fullImageLoader: nil
		)
		
		galleryController.items = [ .image(mediaItem) ]
		galleryController.transitionController = GalleryZoomTransitionController()
		galleryController.availableControls = [ .close, .share ]
		galleryController.initialControlsVisibility = true
		galleryController.sharedControls = true
		galleryController.statusBarStyle = .default
		galleryController.modalPresentationStyle = .fullScreen
		present(galleryController, animated: true, completion: nil)
	}
	
	private func handleDocument(at index: Int) {
		guard let message = chatService.messages[safe: (chatService.messages.count - 1) - index],
			  let attachment = message.getData()?.getAttachment()
		else { return }
		
		let state = attachment.getState()
		
		switch state {
			case .local: // to open
				chatService.openAttachment(for: message, from: self)
			case .remote: // to download
				chatService.downloadAttachment(for: message)
			case .uploading, .downloading: // cancel
				chatService.cancelAttachmentOperation(for: message, with: state)
			case .retry: // download or upload
				chatService.retryAttachmentOperation(for: message)
		}
	}
        
    @objc private func keyboardButtonTap(_ sender: UIBarButtonItem) {
        hideTextInputKeyboard()
    }
    
    // MARK: - UITableViewDelegate methods
    private func setupTableView() {
        tableView?.backgroundColor = .clear
        
        tableView?.separatorStyle = .none
		
        tableView?.registerReusableCell(MessageDocumentAttachmentCell.myCell)
        tableView?.registerReusableCell(MessageDocumentAttachmentCell.operatorCell)
		
		tableView?.registerReusableCell(MessageImageAttachmentCell.myCell)
		tableView?.registerReusableCell(MessageImageAttachmentCell.operatorCell)
		
        tableView?.registerReusableCell(MessageStubCell.reuseIdentifier)
        tableView?.registerReusableCell(MessageChatBotCell.reuseIdentifier)
		
        tableView?.registerReusableCell(MessageTextCell.myCell)
        tableView?.registerReusableCell(MessageTextCell.operatorCell)
		
		tableView?.registerReusableCell(StarsScoreWidgetCell.id)

        if #available(iOS 13.0, *) {
            tableView?.automaticallyAdjustsScrollIndicatorInsets = false
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == chatService.messages.count - 1,
           !chatService.historyWasEmpty {
            requestMessages()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatService.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = chatService.messages[safe: (chatService.messages.count - 1) - indexPath.row]
        else { return UITableViewCell() }
        
        let cell: MessageBubbleCell
        let getMessageActions = { [weak self] in
            return self?.getMessageActions(for: message)
        }
        
        // resolve dependencies _before_ configuring cells!
        switch message.getType() {
            case
                .contactInformationRequest,
                .score,
                .operatorBusy,
                .keyboardResponse,
                .stickerVisitor,
				.unknown:
                cell = tableView.dequeueReusableCell(MessageStubCell.reuseIdentifier)
                container?.resolve(cell)
                
            case .fileFromVisitor:
				if let attachmentUrl = attachmentUrl(from: message),
				   attachmentUrl.isImageFile {
					cell = tableView.dequeueReusableCell(MessageImageAttachmentCell.myCell)
					
					updateImage(for: cell, with: attachmentUrl)
					
				} else {
					let attachmentCell = tableView.dequeueReusableCell(MessageDocumentAttachmentCell.myCell)
					
					message.getData()?.getAttachment()?.addAttachmentStateObserver { state in
						attachmentCell.attachmentStateUpdate(state, isMine: true)
					}
					
					attachmentCell.prepareForReuseCallback = {
						message.getData()?.getAttachment()?.deleteAttachmentStateObserver()
					}
					
					cell = attachmentCell
				}
				
				container?.resolve(cell)
				
				cell.set(
					message: message,
					isMine: true,
					showAvatar: false,
					showName: false,
					showStatus: true,
					getMessageActions: getMessageActions
				)
								
            case .fileFromOperator:
				if let attachmentUrl = attachmentUrl(from: message),
				   attachmentUrl.isImageFile {
					cell = tableView.dequeueReusableCell(MessageImageAttachmentCell.operatorCell)
					
					updateImage(for: cell, with: attachmentUrl)
				} else {
					let attachmentCell = tableView.dequeueReusableCell(MessageDocumentAttachmentCell.operatorCell)
					
					message.getData()?.getAttachment()?.addAttachmentStateObserver { state in
						attachmentCell.attachmentStateUpdate(state, isMine: false)
					}
					
					attachmentCell.prepareForReuseCallback = {
						message.getData()?.getAttachment()?.deleteAttachmentStateObserver()
					}
					
					cell = attachmentCell
				}
				
				container?.resolve(cell)
				
				cell.set(
					message: message,
					isMine: false,
					showAvatar: false,
					showName: false,
					showStatus: false,
					getMessageActions: getMessageActions
				)
                
            case .keyboard:
                guard let state = message.getKeyboard()?.getState() else {
                    cell = tableView.dequeueReusableCell(MessageStubCell.reuseIdentifier)
                    container?.resolve(cell)
                    break
                }
                
                switch state {
                    case .pending:
                        let chatBotCell = tableView.dequeueReusableCell(MessageChatBotCell.reuseIdentifier)
                        chatBotCell.isEnabled = true
                        chatBotCell.delegate = self
                        cell = chatBotCell
                        container?.resolve(cell)
                        cell.set(
                            message: message,
                            isMine: false,
                            showAvatar: true,
                            showName: false,
                            showStatus: false,
                            getMessageActions: getMessageActions
                        )
                        showKeyboardButtonSpinnerIfNeeded(cell: chatBotCell, messageId: message.getID())
                        
                    case .completed:
                        cell = tableView.dequeueReusableCell(MessageTextCell.myCell)
                        container?.resolve(cell)
                        cell.set(
                            message: message,
                            isMine: true,
                            showAvatar: false,
                            showName: false,
                            showStatus: true,
                            getMessageActions: getMessageActions
                        )
                        
                    case .canceled:
                        let chatBotCell = tableView.dequeueReusableCell(MessageChatBotCell.reuseIdentifier)
                        chatBotCell.isEnabled = false
                        chatBotCell.delegate = self
                        cell = chatBotCell
                        container?.resolve(cell)
                        cell.set(
                            message: message,
                            isMine: false,
                            showAvatar: true,
                            showName: false,
                            showStatus: false,
                            getMessageActions: getMessageActions
                        )
                        stopKeyboardButtonSpinner(messageID: message.getID())
                        
                }
                
            case .operatorMessage:
                cell = tableView.dequeueReusableCell(MessageTextCell.operatorCell)
                container?.resolve(cell)
                cell.set(
                    message: message,
                    isMine: false,
                    showAvatar: true,
                    showName: true,
                    showStatus: false,
                    getMessageActions: getMessageActions,
                    linkAction: { [weak self] url in
                        guard let self,
                              let accessToken = self.userSessionService.session?.accessToken,
                              let baseUrl = self.chatService.baseUrl
                        else { return }
                        
                        WebViewer.encryptUrlAndHandleRedirect(
                            url,
                            baseUrl: baseUrl,
                            httpRequestAuthorizer: self.httpRequestAuthorizer,
                            accessToken: accessToken,
                            from: self
                        )
                    }
                )
                
            case .visitorMessage:
                cell = tableView.dequeueReusableCell(MessageTextCell.myCell)
                container?.resolve(cell)
                cell.set(
                    message: message,
                    isMine: true,
                    showAvatar: false,
                    showName: false,
                    showStatus: true,
                    getMessageActions: getMessageActions,
                    linkAction: { [weak self] url in
                        guard let self,
                              let accessToken = self.userSessionService.session?.accessToken,
                              let baseUrl = self.chatService.baseUrl
                        else { return }
                        
                        WebViewer.encryptUrlAndHandleRedirect(
                            url,
                            baseUrl: baseUrl,
                            httpRequestAuthorizer: self.httpRequestAuthorizer,
                            accessToken: accessToken,
                            from: self
                        )
                    }
                )
				
			case .scoreRequest:
				let starsWidgetcell = tableView.dequeueReusableCell(StarsScoreWidgetCell.id)
				starsWidgetcell.ratingSelectedCallback = { [weak self] score in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self?.output.showRateOperator(score)
					}
				}
				
				cell = starsWidgetcell
				
				chatService.saveLastVisibleScoreRequestMessageId(message.getID())
        }
        
        cell.transform = tableView.transform
        return cell
    }
	
	private func updateImage(for cell: MessageBubbleCell, with url: URL) {
		if let imageAttachmentCell = cell as? MessageImageAttachmentCell {
			if url.isFileURL {
				if let image = UIImage(contentsOfFile: url.path) {
					imageAttachmentCell.configure(image)
					imageAttachmentCell.applyCellState(.data)
				}
			} else {
				let operation = chatService.cachedImage(for: url) { result in
					DispatchQueue.main.async {
						switch  result {
							case .success(let image):
								if let image {
									imageAttachmentCell.configure(image)
									imageAttachmentCell.applyCellState(.data)
								} else {
									imageAttachmentCell.applyCellState(.unknown)
								}
							case .failure(let error):
								if (error as? SDWebImageError)?.code != .cancelled {
									self.logger?.warning("Cascana chat image loading request failed with error \(error)")
									imageAttachmentCell.applyCellState(.unknown)
								}
						}
					}
				}
				
				imageAttachmentCell.prepareForReuseCallback = {
					operation?.cancel()
				}
				
				imageAttachmentCell.applyCellState(.processing)
			}
		}
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let message = chatService.messages[safe: (chatService.messages.count - 1) - indexPath.row]
		else { return }
		
		if let attachmentUrl = attachmentUrl(from: message),
		   attachmentUrl.isImageFile {
			showPhoto(at: indexPath.row)
		} else {
			handleDocument(at: indexPath.row)
		}
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let message = chatService.messages[safe: indexPath.row] // fix fatal error
        else { return 1 }
        
        switch message.getType() {
			case .scoreRequest, .contactInformationRequest, .score, .operatorBusy, .stickerVisitor, .unknown:
                return MessageStubCell.height
                
            case .fileFromOperator, .fileFromVisitor:
                return MessageDocumentAttachmentCell.height
                
            case .keyboard:
                guard let state = message.getKeyboard()?.getState()
                else { return 1 }
                
                switch state {
                    case .pending, .canceled:
                        return MessageChatBotCell.height
                    case .completed:
                        return MessageTextCell.height
                }
                
            case .keyboardResponse:
                return 1
                
            case .operatorMessage:
                return MessageTextCell.height
                
            case .visitorMessage:
                return MessageTextCell.height
                
        }
    }
	
	private func attachmentUrl(from message: Message) -> URL? {
		if let attachmentFileInfo = message.getData()?.getAttachment()?.getFileInfo(),
		   let attacmentUrl = attachmentFileInfo.getURL() {
			if attacmentUrl.isFileURL {
				return attacmentUrl
			}
			
			return attacmentUrl.appendingPathComponent(attachmentFileInfo.getFileName(), isDirectory: false)
		}
		   
		return nil
	}
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch chatService.messages[indexPath.row].getType() {
			case .scoreRequest, .contactInformationRequest, .score, .operatorBusy, .stickerVisitor, .unknown:
                return MessageStubCell.estimatedHeight

            case .fileFromOperator, .fileFromVisitor:
                return MessageDocumentAttachmentCell.estimatedHeight

            case .keyboard, .keyboardResponse:
                return MessageChatBotCell.estimatedHeight

            case .operatorMessage:
                return MessageTextCell.estimatedHeight

            case .visitorMessage:
                return MessageTextCell.estimatedHeight

        }
    }
    
    // MARK: - SlackTextViewController methods
    override func didPressLeftButton(_ sender: Any?) {
        textView.refreshFirstResponder()
		output.attachFile()
    }
    
    override func didPressRightButton(_ sender: Any?) { // Send message button
        if let text = textView.text, !text.isEmpty {
            if let messageBeingRepliedTo = messageBeingRepliedTo {
                chatService.reply(with: text, to: messageBeingRepliedTo)
                
                scrollToBottom()
                self.messageBeingRepliedTo = nil
                
            } else {
                chatService.send(message: text)
            }
            textView.text = ""
        }
    }
        
    // MARK: - MessageChatBotDelegate
    func select(cell: MessageChatBotCell, button: KeyboardButton, buttonIndex: KeyboardButtonIndex, message: Message) {
        startKeyboardButtonSpinner(cell: cell, messageId: message.getID(), buttonIndex: buttonIndex)
        
        chatService.sendChatBotHint(button: button, message: message, completionHandler: self)
    }
    
    // MARK: - GalleryZoomTransitionDelegate
    let zoomTransition: GalleryZoomTransition? = nil
    let zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? = nil
    var zoomTransitionAnimatingView: UIView? {
        guard let cell = selectedAttachmentCell,
			  let image = selectedImage
        else { return nil }
        
        let frame = cell.bubbleView.convert(cell.bubbleView.bounds, to: nil)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = frame
        imageView.backgroundColor = .clear
        return imageView
    }
    
    func zoomTransitionHideViews(hide: Bool) {
        guard let cell = selectedAttachmentCell
		else { return }
        
        cell.bubbleView.subviews.first?.isHidden = hide
    }
    
    func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        guard let cell = selectedAttachmentCell else { return .zero }
        
        let frame = tableView?.convert(cell.frame, from: nil)
        return frame ?? .zero
    }
    
    private func showTextInputKeyboard() {
        if !textInputbar.textView.isFirstResponder {
            _ = textInputbar.textView.becomeFirstResponder()
        }
    }
    
    private func hideTextInputKeyboard() {
        _ = textInputbar.textView.resignFirstResponder()
    }
    
    // MARK: - Chat Action Delegates
    
    func onSuccess(messageID: String) {
        hideSpinner()
        stopKeyboardButtonSpinner(messageID: messageID)
        
        if messageBeingEdited != nil {
            updateTextInputbarVisibility()
            messageBeingEdited = nil
        }
        
        if messageBeingDeleted != nil {
            messageBeingDeleted = nil
        }
    }
	
    // MARK: - Actions
    private func requestMessages() {
        chatService.getNextMessages { _ in }
    }
    
    // MARK: - SendKeyboardRequestCompletionHandler
    func onFailure(messageID: String, error: KeyboardResponseError) {
        stopKeyboardButtonSpinner(messageID: messageID)
        
        DispatchQueue.main.async {
            self.logger?.debug(error.displayValue ?? "")
        }
    }
    
    private func getMessageActions(for message: Message) -> MessageActions? {
        if let keyboard = message.getKeyboard(),
           keyboard.getState() != .completed {
            return nil
        }
        
        var replyAction: MessageActionCallback?
        var copyAction: MessageActionCallback?
        var editAction: MessageActionCallback?
        var deleteAction: MessageActionCallback?
		var retryAction: MessageActionCallback?
		var downloadAction: MessageActionCallback?
        
        if message.canBeReplied() {
            replyAction = { [weak self] in
                self?.startReplying(to: message)
            }
        }
        
        if message.canBeCopied {
            copyAction = { [weak self] in
                UIPasteboard.general.string = message.getDisplayedText()
                
                if let self = self {
                    ErrorHelper.show(
                        error: nil,
                        text: NSLocalizedString("chat_message_copied", comment: ""),
                        alertPresenter: self.alertPresenter
                    )
                }
            }
        }
        
        if message.canBeEdited() && !message.isFileAttachment {
            editAction = { [weak self] in
                self?.editMessage(message)
            }
        }
        
        if message.canBeDeleted() {
            deleteAction = { [weak self] in
                self?.deleteMessage(message)
            }
        }
						
		if message.isFileAttachment,
		   let attachment = message.getData()?.getAttachment() {
			switch attachment.getState() {
				case .local, .uploading, .downloading:
					break
				case .remote: // to download
					downloadAction = { [weak self] in
						self?.chatService.downloadAttachment(for: message)
					}
				case .retry: // download or upload
					retryAction = { [weak self] in
						self?.chatService.retryAttachmentOperation(for: message)
					}
			}
		}
		
        return MessageActions(
            reply: replyAction,
            copy: copyAction,
            edit: editAction,
            delete: deleteAction,
			retryOperation: retryAction,
			downloadAttachment: downloadAction
        )
    }
    
    private func deleteMessage(_ message: Message) {
        showSpinner()

        messageBeingDeleted = message
        
        chatService.delete(
            message: message,
            completionHandler: self
        )
    }
    
    private func startReplying(to message: Message) {
        textInputbar.endTextEdition()
        
        messageBeingRepliedTo = message
        quoteView.set(
            author: message.getSenderName(),
            messageText: message.getText() // use text instead of displayed text, since Webim sends text when replying
        )
        isBottomBarViewVisible = true
        
        showTextInputKeyboard()
    }
    
    private func endReplying() {
        messageBeingRepliedTo = nil
        isBottomBarViewVisible = false
    }
    
    private func editMessage(_ message: Message) {
        isTextInputbarHidden = false
        isBottomBarViewVisible = false
        messageBeingEdited = message
        self.editText(message.getText())
    }
    
    override func didCommitTextEditing(_ sender: Any) {
        if let messageBeingEdited = messageBeingEdited,
           let newText = self.textView.text {
            showSpinner()
            chatService.edit(
                message: messageBeingEdited,
                newText: newText,
                completionHandler: self
            )
        }
        super.didCommitTextEditing(sender)
    }
    
    override func didCancelTextEditing(_ sender: Any) {
        super.didCancelTextEditing(sender)
        
        isBottomBarViewVisible = false
        updateTextInputbarVisibility()
    }
    
    // MARK: - DeleteMessageCompletionHandler
    
    func onFailure(messageID: String, error: DeleteMessageError) {
        hideSpinner()
        
        DispatchQueue.main.async {
            self.logger?.debug("\(error)")
            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
        }
    }
    
    // MARK: - EditMessageCompletionHandler
    func onFailure(messageID: String, error: EditMessageError) {
        hideSpinner()
        updateTextInputbarVisibility()
        
        DispatchQueue.main.async {
            self.logger?.debug("\(error)")
            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
        }
    }
    
    private func showSpinner() {
        hideLoadingIndicator?(nil)
        hideLoadingIndicator = self.showLoadingIndicator(
            message: nil,
            in: self
        )
    }
    
    private func hideSpinner() {
        hideLoadingIndicator?(nil)
    }
    
    private func startKeyboardButtonSpinner(cell: MessageChatBotCell, messageId: MessageId, buttonIndex: KeyboardButtonIndex) {
        cell.startSpinner(keyboardButtonIndex: buttonIndex)
        cellsWithSpinners[messageId] = buttonIndex
    }
    
    private func showKeyboardButtonSpinnerIfNeeded(cell: MessageChatBotCell, messageId: MessageId) {
        if let indexOfButtonWithSpinner = cellsWithSpinners[messageId] {
            cell.startSpinner(keyboardButtonIndex: indexOfButtonWithSpinner)
        }
    }
    
    private func stopKeyboardButtonSpinner(messageID: String) {
        if let messageIndex = chatService.getMessageIndex(by: messageID),
           let cell = tableView?.cellForRow(at: IndexPath(
            row: messageIndex, section: 0)
           ) as? MessageChatBotCell {
            cell.stopSpinner()
        }
        
        cellsWithSpinners.removeValue(forKey: messageID)
    }
    
    //bug: .willHide never called
    override func didChangeKeyboardStatus(_ status: SLKKeyboardStatus) {
        if navigationItem.rightBarButtonItems == nil {
            navigationItem.rightBarButtonItems = []
        }
        
        if let keyboardButton = keyboardButton {
            switch status {
                case .willShow:
                    navigationItem.rightBarButtonItems?.append(keyboardButton)
                    keyboardButtonIsVisible = true
                case .didHide:
                    _ = navigationItem.rightBarButtonItems?.popLast()
                    keyboardButtonIsVisible = false
                default:
                    return
            }
        }
    }
    
    // MARK: - UISearchController
	private var previousSearchString = ""
    private var previousSearchResults: [CascanaSearchResult] = []
    private var selectedSearchResultIndexPath: IndexPath?
    
    private func createSearchController() {
        let searchResultsController = ChatSearchResultsViewController()
        searchResultsController.output = .init(
            selectedSearchResult: { [weak self] searchResult in
                guard let self
                else { return }
                                
                func handleSearchResult() {
                    self.navigationItem.searchController?.dismiss(animated: false) { [weak self] in
                        guard let self
                        else { return }
                        
                        self.scrollChat(to: searchResult)
                        self.navigationItem.searchController = nil
                    }
                }
                
                if let messageIndex = self.chatService.getMessageIndex(by: searchResult.messageId) {
                    handleSearchResult()
                } else {
                    self.update(with: .loading)
                    self.chatService.getMessages(to: searchResult.date) {
                        handleSearchResult()
                    }
                }
            }
        )
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        navigationItem.searchController = searchController
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        if #available(iOS 13.0, *) { // on ios 12 results controller will be hidden by system when search string is empty
            searchController.showsSearchResultsController = true
        }
        
        navigationItem.hidesSearchBarWhenScrolling = false
                
        searchController.searchBar.placeholder = NSLocalizedString("chat_searchbar_placeholder", comment: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // no other way to ensure that searchBar receives focus when search controller did appear
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func scrollChat(to searchResult: CascanaSearchResult) {
        guard let messageIndex = chatService.getMessageIndex(by: searchResult.messageId)
        else { return }
        
        let indexPath = IndexPath(row: chatService.messages.count - 1 - messageIndex, section: 0)
        tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        selectedSearchResultIndexPath = indexPath
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let selectedSearchResultIndexPath
        else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self
            else { return }
            
            if let cell = self.tableView?.cellForRow(at: selectedSearchResultIndexPath) as? MessageBubbleCell {
                cell.playAnimation(count: 2) { [weak self] in
                    self?.selectedSearchResultIndexPath = nil
                }
            }
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        navigationItem.searchController?.searchResultsController?.view.isHidden = false
        
        navigationItem.searchController?.searchBar.text = previousSearchString
        
        if previousSearchResults.isEmpty {
            update(with: .emptySearchString)
			previousSearchResults = []
        } else {
            update(with: .filled(previousSearchResults))
        }
    }
	
	private var timer: Timer?
	
	private func setupTimer() {
		invalidateTimer()
		
		let timer = Timer(
			timeInterval: 1,
			target: self,
			selector: #selector(onTimer),
			userInfo: nil,
			repeats: false
		)
		
		RunLoop.main.add(timer, forMode: .default)
		
		self.timer = timer
	}
	
	@objc private func onTimer() {
		guard let searchString = navigationItem.searchController?.searchBar.text
		else { return }
		
		chatService.search(by: searchString) { [weak self] result in
			DispatchQueue.main.async { [weak self] in
				guard let self
				else { return }
				
				switch result {
					case .success(let response):
						if response.messages.isEmpty {
							self.update(with: .emptyResults)
						} else {
							self.update(with: .filled(response.messages))
							self.previousSearchResults = response.messages
						}
						
					case .failure(let error):
						self.update(with: .emptySearchString)
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
				
				self.invalidateTimer()
			}
		}
	}
	
	private func invalidateTimer() {
		timer?.invalidate()
		timer = nil
	}
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = navigationItem.searchController?.searchBar.text {
            if searchString.count > 2 {
                if previousSearchString != searchString {
                    previousSearchString = searchString
                    
                    update(with: .loading)
                    
					setupTimer()
                }
            } else {
				invalidateTimer()
                update(with: .emptySearchString)
				
				previousSearchResults = []
                
                if previousSearchString != searchString {
                    previousSearchString = searchString
                }
            }
        }
    }
    
    private func update(with state: ChatSearchResultsViewController.State) {
        if let resultsController = navigationItem.searchController?.searchResultsController as? ChatSearchResultsViewController {
            resultsController.update(with: state)
        }
    }
        
    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		invalidateTimer()
        searchBar.resignFirstResponder()
        
        previousSearchString = ""
        previousSearchResults = []
        
        searchBar.isHidden = true
        
        if presentingViewController == nil {
            // if chat controller wasn't presented have to nil search controller to exclude blank space under hidden search bar
            navigationItem.searchController = nil
        }
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        leftButton.layer.shadowColor = UIColor.Shadow.buttonShadow.cgColor
        
        rightButton.setImage(
            .Icons.send.tintedImage(withColor: .Icons.iconTertiary),
            for: .normal
        )
        
        textInputbar.setShadowImage(UIImage.backgroundImage(withColor: .Stroke.divider), forToolbarPosition: .bottom)
		
		updateData()
    }
}

private extension Message {
    var canBeCopied: Bool {
        !getDisplayedText().isEmpty && !isFileAttachment
    }
    
    var isFileAttachment: Bool {
        switch self.getType() {
            case .fileFromVisitor, .fileFromOperator:
                return true
                
            case .scoreRequest, .contactInformationRequest, .score, .operatorBusy, .keyboardResponse, .stickerVisitor,
					.keyboard, .operatorMessage, .visitorMessage, .unknown:
                return false
        }
    }
}
// swiftlint:enable file_length
