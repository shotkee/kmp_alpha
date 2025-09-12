//
//  OnboardingViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 21/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import AVFoundation

class OnboardingViewController: ViewController, UIGestureRecognizerDelegate {
    // MARK: - Outlets
    private var progressStackView = UIStackView()
    private var closeButton = UIButton(type: .system)
    private var titleLabel = UILabel()
    private var shadowView = ShadowView()
    private var videoView = UIView()
    private var videoAspectRatioConstraint: NSLayoutConstraint?
    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(onNextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("onboarding_button_title", comment: ""), for: .normal)
        button <~ Style.RoundedButton.redBorderedAndBackgroundClear
        return button
    }()
    
    private lazy var getStartButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(onCompleteButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("onboarding_button_title_end", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()
    
    private lazy var gradientView: GradientView = {
        var value: GradientView = .init(frame: .zero)
        value.startPoint = CGPoint(x: 0.25, y: 0.5)
        value.endPoint = CGPoint(x: 0.75, y: 1)

		value.startColor = .Pallete.accentRed.withAlphaComponent(0)
		value.endColor = .Pallete.accentRed.withAlphaComponent(0.15)
        value.update()
        return value
    }()
    
    private var progressViews: [PageProgressView] = []
    private var player: AVPlayer?
    private var tapStartTime: Date?
    private var beginXPositionLongPress: Double = 0.0
    private var currentStepIndex = 0
    private let pages: [OnboardingPage] = [
        .init(
            title: NSLocalizedString("onboarding_page_title_one", comment: ""),
            videoName: "onboarding-video-1",
            time: 11
        ),
        .init(
            title: NSLocalizedString("onboarding_page_title_two", comment: ""),
            videoName: "onboarding-video-2",
            time: 14
        ),
        .init(
            title: NSLocalizedString("onboarding_page_title_three", comment: ""),
            videoName: "onboarding-video-3",
            time: 12
        ),
        .init(
            title: NSLocalizedString("onboarding_page_title_four", comment: ""),
            videoName: "onboarding-video-4",
            time: 8
        ),
        .init(
            title: NSLocalizedString("onboarding_page_title_five", comment: ""),
            videoName: "onboarding-video-5",
            time: 17
        )
    ]
    
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

    var output: Output!
    
    struct Output {
        let onComplete: () -> Void
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupTimer()
        setupVideo(index: currentStepIndex)
        subscriptionEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        progressViews[currentStepIndex].cancelAnimation()
    }
    
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        setupGradientView()
        setupPageStackView()
        setupCloseButton()
        setupTitleLabel()
        setupShadowView()
        setupVideoView()
        setupSizeVideoView()
        setupGetStartButtonButton()
        setupNextButton()
        setupTaps()
        addContentProgressStackView()
        setContentView(
            pageIndex: currentStepIndex
        )
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
        player?.play()
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
        player?.pause()
        progressViews[currentStepIndex].pauseAnimation()
        progressViews[currentStepIndex].cancelAnimation()
    }
    
    func setupTimer() {
        if let progressView = progressViews[safe: currentStepIndex] {
            progressView.setProgress(0)
            progressView.setProgress(
                1,
                duration: TimeInterval(pages[currentStepIndex].time),
                completion: {
                    self.transitionToNextStepIfPossible()
                }
            )
        }
    }
    
    func pauseTimer()
    {
        if let progressView = progressViews[safe: currentStepIndex]
        {
            progressView.pauseAnimation()
            player?.pause()
        }
    }
    
    func continueTimer()
    {
        if let progressView = progressViews[safe: currentStepIndex]
        {
            progressView.continueAnimation()
            player?.play()
        }
    }
    
    private func setupGradientView() {
        gradientView.isUserInteractionEnabled = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupPageStackView() {
        progressStackView.axis = .horizontal
        progressStackView.distribution = .fillEqually
        progressStackView.spacing = 6
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressStackView)
        
        NSLayoutConstraint.activate([
            progressStackView.heightAnchor.constraint(equalToConstant: 3),
            progressStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            progressStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            progressStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    private func setupCloseButton() {
        closeButton.setImage(
			.Icons.cross,
            for: .normal
        )
		closeButton.tintColor = .Icons.iconAccentThemed
        closeButton.setTitle(nil, for: .normal)
        closeButton.addTarget(
            self,
            action: #selector(onCompleteButtonAction),
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
    
    @objc private func onCompleteButtonAction() {
        output.onComplete()
    }
    
    @objc private func onNextButtonAction() {
        transitionToNextStepIfPossible()
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 13),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    private func setupShadowView() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shadowView)
        NSLayoutConstraint.activate([
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shadowView.widthAnchor.constraint(equalToConstant: view.frame.width - 36)
        ])
        shadowView.layer.cornerRadius = 20
		shadowView.layer <~ ShadowAppearance.cardShadow
		shadowView.backgroundColor = .clear
    }
    
    private func setupVideoView() {
        videoView.clipsToBounds = true
        videoView.layer.cornerRadius = 20
        videoView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.addSubview(videoView)
        
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor)
        ])
    }
    
    private func setupTaps() {
        let gestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onGestureRecognizer(_:))
        )
        gestureRecognizer.minimumPressDuration = 0
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
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
                        transitionToNextStepIfPossible()
                    }
                    else if beginXPositionLongPress < longPressRecongnizer.location(in: view).x
                    {
                        transitionToPreviousStepIfPossible()
                    }
                    else
                    {
                        if beginXPositionLongPress <= view.bounds.width / 4.0
                        {
                            transitionToPreviousStepIfPossible()
                        }
                        else
                        {
                            transitionToNextStepIfPossible()
                        }
                    }
                case .cancelled:
                    break
                
                @unknown default:
                    break
            }
        }
    }
    
    private func setupGetStartButtonButton() {
        getStartButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(getStartButton)
        
        NSLayoutConstraint.activate([
            getStartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            getStartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            getStartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            getStartButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupNextButton() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setVisibleNextAndGetStartButton() {
        nextButton.isHidden = currentStepIndex == pages.count - 1
        getStartButton.isHidden = currentStepIndex != pages.count - 1
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
                animated: true
            )
        }
        else {
            transitionToStep(
                at: currentStepIndex,
                animated: true
            )
        }
    }
    
    func transitionToNextStepIfPossible() {
        updateColorCurrentProgressView(
            currentIndex: currentStepIndex,
            wasLeftSwipe: true
        )
        
        updateCurrentProgressViewFractionComplete()
        
        if currentStepIndex < pages.count - 1
        {
            transitionToStep(
                at: currentStepIndex + 1,
                animated: true
            )
        }
        else
        {
            output.onComplete()
        }
    }
    
    func transitionToStep(
        at stepIndex: Int,
        animated: Bool
    ) {
       
        currentStepIndex = stepIndex
        
        setupTimer()
        setupVideo(index: stepIndex)
        view.layoutIfNeeded()

        setContentView(
            pageIndex: stepIndex
        )
    }
    
    func updateColorCurrentProgressView(
        currentIndex: Int,
        wasLeftSwipe: Bool
    ) {
        progressViews[currentIndex].setProgress(wasLeftSwipe ? 1 : 0)
    }
    
    func setContentView(
        pageIndex: Int
    ) {
        guard let page = pages[safe: pageIndex]
        else { return }
        
        titleLabel.text = page.title
        setVisibleNextAndGetStartButton()
    }
    
    private func setupVideo(index: Int) {
        guard let page = pages[safe: index],
              let videoUrl = createVideoUrl(named: page.videoName)
        else { return }
        
        self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        player = AVPlayer(url: videoUrl)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.borderColor = UIColor.white.cgColor
        playerLayer.borderWidth = 1
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
        player?.play()
    }
    
    private func setupSizeVideoView() {
        guard let videoName = pages[safe: currentStepIndex]?.videoName,
              let videoUrl = createVideoUrl(named: videoName),
              let size = resolutionForLocalVideo(url: videoUrl)
        else { return }
        
        videoAspectRatioConstraint?.isActive = false
        videoAspectRatioConstraint = videoView.heightAnchor.constraint(
            equalTo: shadowView.widthAnchor,
            multiplier: size.height / size.width
        )
        videoAspectRatioConstraint?.isActive = true
    }
    
    private func updateCurrentProgressViewFractionComplete() {
        if let progressView = self.progressViews[safe: currentStepIndex] {
            progressView.fractionComplete = 0
        }
    }
    
    private func addContentProgressStackView() {
        pages.forEach { _ in
            let progressView = PageProgressView()
			progressView.progressTintColor = .Background.backgroundAccent
            progressViews.append(progressView)
            progressStackView.addArrangedSubview(progressView)
        }
    }
    
    private func createVideoUrl(named videoName: String) -> URL? {
        let videoUrl = Bundle.main.url(
            forResource: videoName,
            withExtension: "mp4"
        )
        
        return videoUrl
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first
        else { return nil }
        
        let size = track.naturalSize.applying(
            track.preferredTransform
        )
        
        return CGSize(
            width: abs(size.width),
            height: abs(size.height)
        )
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		gradientView.startColor = .Pallete.accentRed.withAlphaComponent(0)
		gradientView.endColor = .Pallete.accentRed.withAlphaComponent(0.15)
		gradientView.update()
		
		shadowView.layer <~ ShadowAppearance.cardShadow
	}
}
