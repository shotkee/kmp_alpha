//
//  StoryViewController.swift
//  AlfaStrah
//
//  Created by Makson on 04.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import SDWebImage
import Legacy

// swiftlint:disable file_length
class StoryViewController: ViewController, UIGestureRecognizerDelegate
{
    var input: Input!
    var output: Output!
    
    var initialPageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger?
    
    struct Input {
        let isFirstStory: Bool
        let storyPages: [StoryPage]
        let currentViewedPageIndex: Int
    }
    
    struct Output {
        let openWebView: (URL, URL?, @escaping () -> Void) -> Void
        let openBrowser: (URL) -> Void
        let showNextStory: (AnalyticsParam.Stories.PageNavigationTrigger) -> Void
        let showPreviousStory: () -> Void
        let onPageShown: (Int, Bool, AnalyticsParam.Stories.PageNavigationTrigger) -> Void
        let onPageAction: (Int, AnalyticsParam.Stories.PageStatus, AnalyticsParam.Stories.PageAction, URL?, TimeInterval) -> Void
        let updateCurrentViewedPageIndex: (Int) -> Void
        let close: () -> Void
    }
    
    private let progressStackView = UIStackView()
    private let contentStackView = UIStackView()
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let descriptionView = UIView()
    private let descriptionLabel = UILabel()
    private let backgroundImageView = UIImageView()
    private let contentImageView = UIImageView()
    private var contentImageViewAspectRatioConstraint: NSLayoutConstraint?
    private let operationStatusView = OperationStatusView()
    private let actionButton = RoundEdgeButton()
    private let closeButton = UIButton(type: .system)
    private var longPressRecongnizer: UILongPressGestureRecognizer?
    
    // MARK: - Variables
    private var pageStartTime: Date?
    private var currentStepIndex = 0
    private var isVisibleOperationView = false
    private var pageStatus: AnalyticsParam.Stories.PageStatus = .normal
    private var progressViews: [PageProgressView] = []
    private var tapStartTime: Date?
    private var isStopProgress: Bool = false
    private let imageCache = RestStoriesService.createImageCached()
    private var beginXPositionLongPress: Double = 0.0
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool
    {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let location = gestureRecognizer.location(in: view)
        if let hitView = view.hitTest(location, with: nil)
        {
            return !(hitView is UIControl)
        }
        else
        {
            return true
        }
    }
}

// MARK: - Life cycle
extension StoryViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupTimer()
        subscriptionEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isStopProgress {
            progressViews[currentStepIndex].pauseAnimation()
        }
        progressViews[currentStepIndex].cancelAnimation()
        
        longPressRecongnizer?.isEnabled = false
        longPressRecongnizer?.isEnabled = true
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if let backButton = input.storyPages[currentStepIndex].button {
			setupActionButton(buttonConfiguration: backButton)
			actionButton.isHidden = false
		} else {
			actionButton.isHidden = true
		}
	}
}

private extension StoryViewController {
    func setupUI() {
        self.currentStepIndex = input.currentViewedPageIndex
		view.backgroundColor = .Background.backgroundContent
        setupBackgroundImageView()
        setupOperationStatusView()
        setupProgressStackView()
        addContentProgressStackView()
        setupContentStackView()
        setupTaps()
        setupCloseButton()
        setupActionButton()
        setupTitleLabel()
        setupDescriptionLabel()
        addContentStackView()
        setupContentImageView()
        setupSpaceView()
        updateProgressBar()
    }
    
    private func subscriptionEvents() {
        subscribeDidBecomeActiveNotification()
        subscribeWillResignActiveNotification()
    }
    
    private func subscribeDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func didBecomeActiveNotification() {
        setupTimer()
    }
    
    private func subscribeWillResignActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActiveNotification),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc func willResignActiveNotification() {
        progressViews[currentStepIndex].pauseAnimation()
        progressViews[currentStepIndex].cancelAnimation()
    }
    
    private func updateProgressBar() {
        if currentStepIndex != 0 {
            for index in 0 ..< self.currentStepIndex {
                if let progressView = progressViews[safe: index] {
                    progressView.setProgress(0)
                    progressView.setProgress(1)
                }
            }
        }
    }
    
    private func setupTaps()
    {
        let gestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onGestureRecognizer(_:))
        )
        gestureRecognizer.minimumPressDuration = 0
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        longPressRecongnizer = gestureRecognizer
    }
    
    func setupProgressStackView() {
        progressStackView.axis = .horizontal
        progressStackView.distribution = .fillEqually
        progressStackView.spacing = 6
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressStackView)
        
        NSLayoutConstraint.activate([
            progressStackView.heightAnchor.constraint(equalToConstant: 3),
            progressStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            progressStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            progressStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    func setupCloseButton() {
        closeButton.setImage(
            UIImage(named: "ico-nav-cancel"),
            for: .normal
        )
        closeButton.setTitle(nil, for: .normal)
        closeButton.addTarget(
            self,
            action: #selector(сloseButtonTap),
            for: .touchUpInside
        )
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.topAnchor.constraint(equalTo: progressStackView.bottomAnchor, constant: 18),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    func setupTimer() {
        pageStartTime = Date()
        
        if let progressView = progressViews[safe: currentStepIndex] {
            progressView.setProgress(0)
            progressView.setProgress(
                1,
                duration: TimeInterval(input.storyPages[currentStepIndex].time),
                completion: {
                    self.transitionToNextStepIfPossible(pageNavigationTrigger: .timer)
                }
            )
        }
    }
    
    func pauseTimer()
    {
        if let progressView = progressViews[safe: currentStepIndex]
        {
            onPageAction(.pause)
            
            progressView.pauseAnimation()
        }
    }
    
    func continueTimer()
    {
        if let progressView = progressViews[safe: currentStepIndex]
        {
            progressView.continueAnimation()
        }
    }
    
    func setupActionButton() {
        actionButton.clipsToBounds = true
        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -9),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18)
        ])
    }
    
    func checkCachedAndsSetupImages(
        storyPage: StoryPage
    ) -> Bool {
        guard let body = storyPage.body
        else {
            return false
        }
        
        switch (body.backgroundImageType, body.imageType) {
            case (.image, .image):
                let backgroundImage = getImageFromCache(
                    url: body.backgroundImage
                )
            
                let contentImage = getImageFromCache(
                    url: body.image
                )
            
                setupImages(
                    contentImage: contentImage,
                    backgroundImage: backgroundImage,
                    backgroundColor: body.backgroundColor,
                    backgroundImageType: body.backgroundImageType
                )
            
                return contentImage != nil && backgroundImage != nil
            
            case (_, .image):
                let contentImage = getImageFromCache(
                    url: body.image
                )
           
                setupImages(
                    contentImage: contentImage,
                    backgroundImage: nil,
                    backgroundColor: body.backgroundColor,
                    backgroundImageType: body.backgroundImageType
                )
            
                return contentImage != nil
            
            case (.image, _):
                let backgroundImage = getImageFromCache(
                    url: body.backgroundImage
                )
            
                setupImages(
                    contentImage: nil,
                    backgroundImage: backgroundImage,
                    backgroundColor: body.backgroundColor,
                    backgroundImageType: body.backgroundImageType
                )
            
                return backgroundImage != nil
            
            default:
                return false
        }
    }
    
    func getImageFromCache(
        url: URL?
    ) -> UIImage? {
        
        if let image = imageCache.imageFromDiskCache(
            forKey: url?.absoluteString
        ) {
            return image
        }
        else if let image = imageCache.imageFromMemoryCache(
            forKey: url?.absoluteString
        ) {
            return image
        }
        
        return nil
    }
    
    private func setupImages(
        contentImage: UIImage?,
        backgroundImage: UIImage?,
        backgroundColor: String?,
        backgroundImageType: StoryPageBody.BackgroundImageType
    ) {
        setupBackgroundImage(
            image: backgroundImage,
            backgroundColor: backgroundColor,
            backgroundImageType: backgroundImageType
        )
        
        setupContentImageView(
            image: contentImage
        )
    }
    
    func loadingImageBackgroundAndContentImage(
        storyPage: StoryPage,
        pageIndex: Int,
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        var isError = false
        
        setupLoadingStateOperationView()
        
        guard let body = storyPage.body
        else {
            setVisibleOperationView(
                isVisible: false,
                button: storyPage.button
            )
            
            return
        }
        
        switch (body.backgroundImageType, body.imageType) {
            case (.image, .image):
                pageStatus = .loading
                
                backgroundImageView.sd_setImage(
                    with: body.backgroundImage,
                    placeholderImage: nil,
                    options: [],
                    context: [.imageCache: RestStoriesService.createImageCached()],
                    progress: nil,
                    completed: { [weak self] backgroundImage, _, _, _ in
                        if backgroundImage == nil {
                            isError = true
                        }
                    
                        self?.contentImageView.sd_setImage(
                            with: body.image,
                            placeholderImage: nil,
                            options: [],
                            context: [.imageCache: RestStoriesService.createImageCached()],
                            progress: nil,
                            completed: { [weak self] image, _, _, _ in
                            
                                if image == nil {
                                    isError = true
                                }
                            
                                self?.setupImages(
                                    contentImage: image,
                                    backgroundImage: backgroundImage,
                                    backgroundColor: body.backgroundColor,
                                    backgroundImageType: body.backgroundImageType
                                )
                            
                                isError
                                    ? self?.setupErrorStateOperationView(
                                        storyPage: storyPage,
                                        pageIndex: pageIndex,
                                        pageNavigationTrigger: pageNavigationTrigger
                                    )
                                    : self?.successfulDownloadImages(
                                        button: storyPage.button,
                                        pageHasLoading: true,
                                        pageIndex: pageIndex,
                                        pageNavigationTrigger: pageNavigationTrigger
                                    )
                            }
                        )
                    }
                )
            case (_, .image):
                pageStatus = .loading
                
                contentImageView.sd_setImage(
                    with: body.image,
                    placeholderImage: nil,
                    options: [],
                    context: [.imageCache: RestStoriesService.createImageCached()],
                    progress: nil,
                    completed: { [weak self] image, _, _, _ in
                    
                        if image == nil {
                            isError = true
                        }
                    
                        self?.setupImages(
                            contentImage: image,
                            backgroundImage: nil,
                            backgroundColor: body.backgroundColor,
                            backgroundImageType: body.backgroundImageType
                        )
                    
                        isError
                            ? self?.setupErrorStateOperationView(
                                storyPage: storyPage,
                                pageIndex: pageIndex,
                                pageNavigationTrigger: pageNavigationTrigger
                            )
                            : self?.successfulDownloadImages(
                                button: storyPage.button,
                                pageHasLoading: true,
                                pageIndex: pageIndex,
                                pageNavigationTrigger: pageNavigationTrigger
                            )
                    }
                )
            case (.image, _):
                pageStatus = .loading
                
                backgroundImageView.sd_setImage(
                    with: storyPage.body?.backgroundImage,
                    placeholderImage: nil,
                    options: [],
                    context: [.imageCache: RestStoriesService.createImageCached()],
                    progress: nil,
                    completed: { [weak self] image, _, _, _ in
                    
                        if image == nil {
                            isError = true
                        }
                    
                        self?.setupImages(
                            contentImage: nil,
                            backgroundImage: image,
                            backgroundColor: body.backgroundColor,
                            backgroundImageType: body.backgroundImageType
                        )
                    
                        isError
                            ? self?.setupErrorStateOperationView(
                                storyPage: storyPage,
                                pageIndex: pageIndex,
                                pageNavigationTrigger: pageNavigationTrigger
                            )
                            : self?.successfulDownloadImages(
                                button: storyPage.button,
                                pageHasLoading: true,
                                pageIndex: pageIndex,
                                pageNavigationTrigger: pageNavigationTrigger
                            )
                    }
                )
            default:
                self.setupImages(
                    contentImage: nil,
                    backgroundImage: nil,
                    backgroundColor: body.backgroundColor,
                    backgroundImageType: body.backgroundImageType
                )
            
                successfulDownloadImages(
                    button: storyPage.button,
                    pageHasLoading: false,
                    pageIndex: pageIndex,
                    pageNavigationTrigger: pageNavigationTrigger
                )
        }
    }
    
    private func successfulDownloadImages(
        button: BackendButton?,
        pageHasLoading: Bool,
        pageIndex: Int,
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        pageStatus = .normal
        
        output.onPageShown(
            pageIndex,
            pageHasLoading,
            pageNavigationTrigger
        )
        
        setVisibleOperationView(
            isVisible: false,
            button: button
        )
    }
    
    func setContentView(
        pageIndex: Int,
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        guard let storyPage = input.storyPages[safe: pageIndex]
        else { return }
        
		if let backButton = storyPage.button {
			setupActionButton(buttonConfiguration: backButton)
			actionButton.isHidden = false
		} else {
			actionButton.isHidden = true
		}
        
        if !checkCachedAndsSetupImages(storyPage: storyPage) {
            loadingImageBackgroundAndContentImage(
                storyPage: storyPage,
                pageIndex: pageIndex,
                pageNavigationTrigger: pageNavigationTrigger
            )
        }
        else {
            output.onPageShown(
                pageIndex,
                false,
                pageNavigationTrigger
            )
        }
        
		closeButton.tintColor = .from(hex: storyPage.crossColor)
        
        if let body = storyPage.body
        {
            setupTitleLabel(
                title: body.title,
                titleColor: body.titleColor
            )
            setupDescriptionLabel(
                text: body.text,
                textColor: body.textColor
            )
        }
    }
    
    func setupTitleLabel(
        title: String?,
        titleColor: String?
    ){
        titleView.isHidden = title == nil
        titleLabel.text = title
        
        guard let titleColor = titleColor
        else { return }
        titleLabel.textColor = .from(hex: titleColor)
    }
    
    func setupDescriptionLabel(
        text: String?,
        textColor: String?
    ){
        descriptionView.isHidden = text == nil
        descriptionLabel.text = text
        
        guard let textColor = textColor
        else { return }
        descriptionLabel.textColor = .from(hex: textColor)
    }
    
    func setupContentImageView(
        image: UIImage?
    ) {
        contentImageView.isHidden = image == nil
        contentImageView.image = image
        if let image = image {
            let size = image.size
            contentImageViewAspectRatioConstraint?.isActive = false
            contentImageViewAspectRatioConstraint = contentImageView.heightAnchor.constraint(
                equalTo: contentImageView.widthAnchor,
                multiplier: size.height / size.width
            )
            contentImageViewAspectRatioConstraint?.isActive = true
        }
    }
    
    func setupBackgroundImage(
        image: UIImage?,
        backgroundColor: String?,
        backgroundImageType: StoryPageBody.BackgroundImageType
    ) {
        switch backgroundImageType {
            case .image:
                backgroundImageView.isHidden = image == nil
                backgroundImageView.image = image
				view.backgroundColor = .Background.backgroundContent
            case .colorFill:
                backgroundImageView.isHidden = true
                guard let backgroundColor = backgroundColor
                else {
					view.backgroundColor = .Background.backgroundContent
                    return
                }
                view.backgroundColor = .from(hex: backgroundColor)
        }
    }
	
    func setupActionButton(
		buttonConfiguration: BackendButton
    ) {
		let textColor = buttonConfiguration.textHexColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonConfiguration.textHexColor)
		let backgroundColor = buttonConfiguration.backgroundHexColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonConfiguration.backgroundHexColor)
		
		if let textColor, let backgroundColor {
			actionButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: textColor,
				backgroundColor: backgroundColor
			)
		} else {
			actionButton <~ Style.RoundedButton.redParameterizedButton
		}

		actionButton.setTitle(
			buttonConfiguration.action.title,
			for: .normal
		)
    }
    
    func setupContentStackView() {
        contentStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        contentStackView.axis = .vertical
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.isUserInteractionEnabled = false
        view.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    private func setVisibleOperationView(
        isVisible: Bool,
        button: BackendButton?
    ) {
        operationStatusView.isHidden = !isVisible
        contentStackView.isHidden = isVisible
        actionButton.isHidden = button == nil
    }
    
    func setupErrorStateOperationView(
        storyPage: StoryPage,
        pageIndex: Int,
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        let state: OperationStatusView.State = .info(.init(
            title: NSLocalizedString("stories_error_title", comment: ""),
            description: NSLocalizedString("stories_error_description", comment: ""),
            icon: UIImage(named: "icon-common-failure")
        ))
        
        let button: OperationStatusView.ButtonConfiguration = .init(
            title: NSLocalizedString("stories_retry_title_button", comment: ""),
            isPrimary: true,
            action: { [weak self] in
                self?.loadingImageBackgroundAndContentImage(
                    storyPage: storyPage,
                    pageIndex: pageIndex,
                    pageNavigationTrigger: pageNavigationTrigger
                )
            }
        )
        
        operationStatusView.notify.updateState(state)
        operationStatusView.notify.buttonConfiguration([button])
        setVisibleOperationView(
            isVisible: true,
            button: nil
        )
        
        pageStatus = .error
    }
    
    func setupLoadingStateOperationView() {
        let state: OperationStatusView.State = .loading(.init(
            title: NSLocalizedString("stories_loading_text", comment: ""),
            description: nil,
            icon: nil
        ))
        operationStatusView.notify.updateState(state)
        setVisibleOperationView(
            isVisible: true,
            button: nil
        )
    }
    
    func setupTitleLabel() {
        titleView.backgroundColor = .clear
        contentStackView.addArrangedSubview(titleView)
        contentStackView.setCustomSpacing(15, after: titleView)
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -18),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
    }
    
    func setupDescriptionLabel() {
        descriptionView.backgroundColor = .clear
        contentStackView.addArrangedSubview(descriptionView)
        contentStackView.setCustomSpacing(36, after: descriptionView)
        descriptionLabel <~ Style.Label.primaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -18),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 18),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor)
        ])
    }
    
    func setupBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func setupContentImageView() {
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.layer.masksToBounds = true
        contentImageView.clipsToBounds = true
        contentStackView.addArrangedSubview(contentImageView)
    }
    
    func setupOperationStatusView() {
        operationStatusView.isHidden = true
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: operationStatusView, in: view)
        )
    }
    
    func setupSpaceView() {
        let view = UIView()
        view.backgroundColor = .clear
        contentStackView.addArrangedSubview(view)
    }
    
    func addContentProgressStackView() {
        for index in 0..<input.storyPages.count {
            let progressView = PageProgressView()
			progressView.progressTintColor = .from(
				hex: input.storyPages[index].stripeColor
			) ?? .Background.backgroundAccent
            progressViews.append(progressView)
            progressStackView.addArrangedSubview(progressView)
        }
    }
    
    func addContentStackView() {
        setContentView(
            pageIndex: currentStepIndex,
            pageNavigationTrigger: initialPageNavigationTrigger ?? .initial
        )
    }
    
    func updateColorCurrentProgressView(
        currentIndex: Int,
        wasLeftSwipe: Bool
    ) {
        progressViews[currentIndex].setProgress(wasLeftSwipe ? 1 : 0)
    }
    
    @objc func onRightSwipeGesture()
    {
        onPageAction(.swipeRight)
        
        if input.isFirstStory {
            updateColorCurrentProgressView(
                currentIndex: currentStepIndex,
                wasLeftSwipe: true
            )
            
            updateCurrentProgressViewFractionComplete()
            
            setupTimer()
        }
        else {
            output.showPreviousStory()
        }
    }
    
    @objc func onLeftSwipeGesture()
    {
        onPageAction(.swipeLeft)
        
        output.showNextStory(.userAction)
    }
    
    @objc func onGestureRecognizer(_ recognizer: UIGestureRecognizer)
    {
        if let longPressRecongnizer = recognizer as? UILongPressGestureRecognizer {
            switch longPressRecongnizer.state
            {
                case .possible,
                        .failed:
                    break
                
                case .began:
                    beginXPositionLongPress = longPressRecongnizer.location(in: view).x
                    tapStartTime = Date()
                    pauseTimer()
                    
                case .changed:
                    break
                    
                case .ended:
                    if let tapStartTime = tapStartTime,
                       Date().timeIntervalSince(tapStartTime) > 0.2
                    {
                        continueTimer()
                    }
                    else if beginXPositionLongPress > longPressRecongnizer.location(in: view).x
                    {
                        onLeftSwipeGesture()
                    }
                    else if beginXPositionLongPress < longPressRecongnizer.location(in: view).x {
                        onRightSwipeGesture()
                    }
                    else {
                        if beginXPositionLongPress <= view.bounds.width / 4.0
                        {
                            onLeftTap()
                        }
                        else
                        {
                            onRightTap()
                        }
                    }
                case .cancelled:
                    break
                
                @unknown default:
                    break
            }
        }
    }
    
    func onLeftTap()
    {
        onPageAction(.leftTap)
        
        transitionToPreviousStepIfPossible()
    }
    
    func onRightTap()
    {
        onPageAction(.rightTap)
        
        transitionToNextStepIfPossible(pageNavigationTrigger: .userAction)
    }
    
    func transitionToPreviousStepIfPossible()
    {
        updateColorCurrentProgressView(
            currentIndex: currentStepIndex,
            wasLeftSwipe: false
        )
        
        updateCurrentProgressViewFractionComplete()
        
        if currentStepIndex > 0
        {
            transitionToStep(
                at: currentStepIndex - 1,
                animated: true,
                pageNavigationTrigger: .userAction
            )
        } else if input.isFirstStory {
            transitionToStep(
                at: currentStepIndex,
                animated: true,
                pageNavigationTrigger: .userAction
            )
        } else {
            output.showPreviousStory()
        }
    }
    
    func transitionToNextStepIfPossible(
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        guard !isStopProgress
        else { return }
        
        updateColorCurrentProgressView(
            currentIndex: currentStepIndex,
            wasLeftSwipe: true
        )
        
        updateCurrentProgressViewFractionComplete()
        
        if currentStepIndex < input.storyPages.count - 1
        {
            transitionToStep(
                at: currentStepIndex + 1,
                animated: true,
                pageNavigationTrigger: pageNavigationTrigger
            )
        }
        else
        {
            output.showNextStory(pageNavigationTrigger)
        }
    }
    
    func transitionToStep(
        at stepIndex: Int,
        animated: Bool,
        pageNavigationTrigger: AnalyticsParam.Stories.PageNavigationTrigger
    ) {
        output.updateCurrentViewedPageIndex(stepIndex)
        currentStepIndex = stepIndex
        
        setupTimer()
        view.layoutIfNeeded()
        operationStatusView.isHidden = true

        setContentView(
            pageIndex: stepIndex,
            pageNavigationTrigger: pageNavigationTrigger
        )
    }
    
    private func updateCurrentProgressViewFractionComplete(){
        if let progressView = self.progressViews[safe: currentStepIndex] {
            progressView.fractionComplete = 0
        }
    }
}

// MARK: - Actions
private extension StoryViewController {
    @objc func actionButtonTap() {
        guard let buttonAction = input.storyPages[currentStepIndex].button?.action
        else { return }
        
        switch buttonAction.type {
            case
                .insurance,
                .offlineAppointment,
                .onlineAppointment,
                .osagoReport,
                .kaskoReport,
                .loyalty,
                .propertyProlongation,
                .telemedicine,
                .clinicAppointment,
                .doctorCall,
                .none:
                break
            case .path(url: let url, urlShareable: let urlShareable, openMethod: let method):
                onPageAction(
                    .button,
                    link: url
                )
                
                openURL(
                    url: url,
                    urlShareable: urlShareable,
                    urlType: method
                )
        }
    }
    
    private func openURL(
        url: URL,
        urlShareable: URL?,
        urlType: BackendAction.UrlOpenMethod
    ) {
        switch urlType {
            case .webview:
                self.isStopProgress = true
                output.openWebView(
                    url,
                    urlShareable,
                    { [weak self] in
                        guard let self = self
                        else { return }
                        
                        self.isStopProgress = false
                    }
                )
            case .external:
                output.openBrowser(url)
        }
    }
    
    @objc private func сloseButtonTap() {
        onPageAction(.close)
        
        output.close()
    }
    
    func onPageAction(
        _ action: AnalyticsParam.Stories.PageAction,
        link: URL? = nil
    )
    {
        output.onPageAction(
            currentStepIndex,
            pageStatus,
            action,
            link,
            pageStartTime
                .map { Date().timeIntervalSince($0) }
                ?? 0
        )
    }
}
