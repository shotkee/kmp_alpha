//
//  CreateAutoEventViewController
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 27.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class CreateAutoEventViewController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!

    struct Input {
        var photoGroups: [PhotoGroup]
        var insurance: Insurance
        var draft: AutoEventDraft?
		var caseType: AutoEventCaseType
        var isDemo: Bool
        var locationInfo: () -> LocationInfo
    }

    struct Output {
        var loadLocation: (Coordinate) -> Void
        var pickLocation: () -> Void
        var inputTextAddress: (String?, @escaping (String?) -> Void) -> Void
        var saveDraft: (AutoEventDraft) -> Void
        var createEvent: (CreateAutoEventReport, _ isDraft: Bool, _ completion: @escaping () -> Void) -> Void
        var photoGroup: (PhotoGroup) -> Void
        var goBack: () -> Void
    }

    struct Notify {
        var locationUpdated: () -> Void
        var photosUpdated: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        locationUpdated: { [weak self] in
            guard let self = self else { return }

            self.model.locationInfo = self.input.locationInfo()
        },
        photosUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    deinit {
        // Delete attachments from disk
        let attachments = input.photoGroups.flatMap { $0.photos }
        attachments.forEach { attachmentService.delete(attachment: $0) }
    }

    @IBOutlet private var sendButton: RoundEdgeButton!
    @IBOutlet private var locationInputContainer: UIView!
	@IBOutlet private var insuranceHeader: UILabel!
    @IBOutlet private var insuranceTitle: UILabel!
    @IBOutlet private var insuredObject: UILabel!
    @IBOutlet private var accidentDescriptionViewContainer: UIView!
    @IBOutlet private var accidentDateViewContainer: UIView!
    @IBOutlet private var accidentDateParentContainerView: UIView!
    @IBOutlet private var accidentTimeViewContainer: UIView!
    @IBOutlet private var accidentTimeParentContainerView: UIView!

    @IBOutlet private var placePhotoGroup: PhotoGroupInfoView!
    @IBOutlet private var planPhotoGroup: PhotoGroupInfoView!
    @IBOutlet private var damagePhotoGroup: PhotoGroupInfoView!
    @IBOutlet private var vinPhotoGroup: PhotoGroupInfoView!
    @IBOutlet private var docsPhotoGroup: PhotoGroupInfoView!

    @IBOutlet private var selectDateTap: UITapGestureRecognizer!
    @IBOutlet private var selectTimeTap: UITapGestureRecognizer!
    @IBOutlet private var selectDateView: SelectDateView!
    @IBOutlet private var selectTimeView: SelectDateView!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
	
	@IBOutlet private var descriptionInHeaderLabel: UILabel!
	@IBOutlet private var photosNoteTitle: UILabel!
	@IBOutlet private var photosNoteDescription: UILabel!
	
	@IBOutlet private var locationPhotosTitleLabel: UILabel!
	@IBOutlet private var locationPhotosCounterLabel: UILabel!
	@IBOutlet private var commonSchemePhotosTitleLabel: UILabel!
	@IBOutlet private var commonSchemePhotosCounterLabel: UILabel!
	@IBOutlet private var damagedPartsPhotosTitleLabel: UILabel!
	@IBOutlet private var damagedPartsPhotosCounterLabel: UILabel!
	@IBOutlet private var vinAndPanelPhotosTitleLabel: UILabel!
	@IBOutlet private var vinAndPanelPhotosCounterLabel: UILabel!
	@IBOutlet private var documentsPhotosTitleLabel: UILabel!
	@IBOutlet private var documentsPhotosCounterLabel: UILabel!
	
	private var model: FormModel! {
        didSet {
            updateUI()
        }
    }
    private var photoGroups: [PhotoGroup] = []
    private var draft: AutoEventDraft?
    private var lastCoordinate: Coordinate?
    private var lastAddress: String?
    private weak var accidentDescriptionView: CommonNoteView?
    private weak var accidentDateView: CommonNoteLabelView?
    private weak var accidentTimeView: CommonNoteLabelView?

    private static let dateFormatter: DateFormatter = DateFormatter(dateFormat: "dd.MM.yyyy")
    private static let timeFormatter: DateFormatter = DateFormatter(dateFormat: "HH:mm")

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
		sendButton <~ Style.RoundedButton.redBackground
		
		insuranceHeader <~ Style.Label.secondaryCaption1
		insuranceTitle <~ Style.Label.primaryHeadline1
		insuredObject <~ Style.Label.primaryText
		
		descriptionInHeaderLabel <~ Style.Label.secondarySubhead
		photosNoteTitle <~ Style.Label.secondaryHeadline2
		photosNoteDescription <~ Style.Label.secondaryText
		
		locationPhotosTitleLabel <~ Style.Label.primaryHeadline2
		locationPhotosCounterLabel <~ Style.Label.secondaryCaption1
		commonSchemePhotosTitleLabel <~ Style.Label.primaryHeadline2
		commonSchemePhotosCounterLabel <~ Style.Label.secondaryCaption1
		damagedPartsPhotosTitleLabel <~ Style.Label.primaryHeadline2
		damagedPartsPhotosCounterLabel <~ Style.Label.secondaryCaption1
		vinAndPanelPhotosTitleLabel <~ Style.Label.primaryHeadline2
		vinAndPanelPhotosCounterLabel <~ Style.Label.secondaryCaption1
		documentsPhotosTitleLabel <~ Style.Label.primaryHeadline2
		documentsPhotosCounterLabel <~ Style.Label.secondaryCaption1
		
        title = NSLocalizedString("insurance_case", comment: "")
        model = FormModel(
            insurance: input.insurance,
            locationInfo: input.locationInfo(),
            causes: "",
            date: nil
        )
        draft = input.draft
        photoGroups = input.photoGroups

        selectDateView.toggleDateMode()
        selectTimeView.toggleTimeMode()

        let dateUpdated = { [unowned self] (date: Date) in
            self.checkInsuranceDate(date)
        }
        selectDateView.onDateSelected = dateUpdated
        selectTimeView.onDateSelected = dateUpdated

        setupLocationView()

        let accidentDescriptionView: CommonNoteView = .init()
        self.accidentDescriptionView = accidentDescriptionView
        accidentDescriptionView.set(
            title: NSLocalizedString("auto_event_report_event_description_title", comment: ""),
            note: "",
            placeholder: NSLocalizedString("auto_event_report_event_description_hint", comment: ""),
            margins: Style.Margins.defaultInsets,
            showSeparator: false
        )
        accidentDescriptionView.textViewChangedCallback = { [unowned self] in
            self.model.causes = $0.text ?? ""
        }
        accidentDescriptionView.textViewHeightChangedCallback = { [unowned self] _ in
            self.scrollView.scrollRectToVisible(self.accidentDescriptionViewContainer.frame, animated: true)
        }
        accidentDescriptionView.textViewDidBecomeActiveCallback = { [unowned self] _ in
            self.hidePickers()
        }
        accidentDescriptionViewContainer.addSubview(accidentDescriptionView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: accidentDescriptionView, in: accidentDescriptionViewContainer))
        let accidentDateView: CommonNoteLabelView = .init()
        self.accidentDateView = accidentDateView
        accidentDateView.set(
            title: NSLocalizedString("auto_event_report_event_date_title", comment: ""),
            note: "",
            placeholder: NSLocalizedString("auto_event_report_event_date_hint", comment: ""),
            margins: Style.Margins.defaultInsets,
            showSeparator: false
        )
        accidentDateViewContainer.addSubview(accidentDateView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: accidentDateView, in: accidentDateViewContainer))
        let accidentTimeView: CommonNoteLabelView = .init()
        self.accidentTimeView = accidentTimeView
        accidentTimeView.set(
            title: NSLocalizedString("auto_event_report_event_time_title", comment: ""),
            note: "",
            placeholder: NSLocalizedString("auto_event_report_event_time_hint", comment: ""),
            margins: Style.Margins.defaultInsets,
            showSeparator: false
        )
        accidentTimeViewContainer.addSubview(accidentTimeView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: accidentTimeView, in: accidentTimeViewContainer))
		if !input.isDemo
		{
			navigationItem.rightBarButtonItem = UIBarButtonItem(
				title: NSLocalizedString("common_save", comment: ""),
				style: .plain,
				target: self,
				action: #selector(saveDraftAndTrack)
			)
		}

        keyboardBehaviorSetup()

        if let draft = draft {
            loadDraft(draft)
        }
    }

    func checkInsuranceDate(_ date: Date) {
        if (input.insurance.startDate...input.insurance.endDate).contains(date) {
            model.date = date
            hidePickers()
        } else {
            let alertTitle: String
            if date < input.insurance.startDate {
                alertTitle = String(format: NSLocalizedString("insurance_event_date_alert_not_started", comment: ""),
                    input.insurance.insuredObjectTitle, AppLocale.shortDateString(input.insurance.startDate))
            } else {
                alertTitle = String(format: NSLocalizedString("insurance_event_date_alert_expired", comment: ""),
                    input.insurance.insuredObjectTitle, AppLocale.shortDateString(input.insurance.endDate))
            }
            let alertView = UIAlertController(
                title: nil,
                message: alertTitle,
                preferredStyle: .alert
            )
            let changeAction = UIAlertAction(
                title: NSLocalizedString("insurance_event_date_alert_change", comment: ""),
                style: .default
            )
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("insurance_event_date_alert_cancel", comment: ""),
                style: .default
            ) { _ in
                self.hidePickers()
            }
            alertView.addAction(cancelAction)
            alertView.addAction(changeAction)
            present(alertView, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(false)
        hidePickers()
        keyboardBehavior.unsubscribe()
    }

    // MARK: - Keyboard

    private let keyboardBehavior: KeyboardBehavior = KeyboardBehavior()
    private var defaultInsets: UIEdgeInsets = .zero

    private func keyboardBehaviorSetup() {
        defaultInsets = scrollView.contentInset
        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let `self` = self else { return }

            let frameInView = self.scrollView.convert(frame, from: nil)
            let bottomInset = max(self.scrollView.bounds.maxY - frameInView.minY, 0)

            var insets = self.defaultInsets
            insets.bottom = max(insets.bottom, bottomInset)

            self.scrollView.contentInset = insets
            self.scrollView.scrollIndicatorInsets = insets
        }
    }

    // MARK: - Model updates

    private func updateUI() {
        guard self.isViewLoaded else { return }

        let totalPhotos = photoGroups.reduce(0) { $0 + $1.totalPhotos }
        let text = "\(totalPhotos)" + " " + NSLocalizedString("auto_event_photo", comment: "")
		sendButton.setTitle(text, for: .normal)
		
        sendButton.isEnabled = formIsReady()

        insuranceTitle.text = model.insurance.title
        insuredObject.text = model.insurance.insuredObjectTitle
        accidentDescriptionView?.updateText(model.causes)

        let dateFormatter = CreateAutoEventViewController.dateFormatter
        let timeFormatter = CreateAutoEventViewController.timeFormatter
        if let date = model.date {
            accidentDateView?.updateText(dateFormatter.string(from: date))
            accidentTimeView?.updateText(timeFormatter.string(from: date))
        }

        for group in photoGroups {
            switch group.type {
                case .place:
                    placePhotoGroup.set(photoCount: group.photoCountText, isReady: group.isReady)
                case .plan:
                    planPhotoGroup.set(photoCount: group.photoCountText, isReady: group.isReady)
                case .damage:
                    damagePhotoGroup.set(photoCount: group.photoCountText, isReady: group.isReady)
                case .vin:
                    vinPhotoGroup.set(photoCount: group.photoCountText, isReady: group.isReady)
                case .docs:
                    docsPhotoGroup.set(photoCount: group.photoCountText, isReady: group.isReady)
            }
        }

        updateLocationViewIfNeeded()
    }

    private func formIsReady() -> Bool {
        let photosReady = photoGroups.allSatisfy { $0.isReady }
        return model.isReady && photosReady
    }

    // MARK: - Location

    private let locationView: LocationInfoView = .fromNib()

    private func updateLocationViewIfNeeded() {
        let nextCoordinate = input.locationInfo().position
        let nextAddress = input.locationInfo().address
        guard lastCoordinate != nextCoordinate || lastAddress != nextAddress else { return }

        locationView.configure(
            coordinate: nextCoordinate?.clLocationCoordinate,
            address: nextAddress,
            isInsuranceEvent: false
        )
        lastCoordinate = nextCoordinate
        lastAddress = nextAddress
    }
	
	func updateLocationView(text: String)
	{
		locationView.updateTextInput(text: text)
	}

    private func setupLocationView() {
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.configure(
            coordinate: input.locationInfo().position?.clLocationCoordinate,
            address: input.locationInfo().address,
            isInsuranceEvent: false
        )
        locationView.mapTapAction = { [weak self] in
            self?.output.pickLocation()
        }
        locationView.addressInputTapAction = { [weak self, weak locationView] currentAddress in
            self?.output.inputTextAddress(currentAddress) { addressString in
                locationView?.configure(coordinate: nil, address: addressString, isInsuranceEvent: false)
            }
        }
        locationInputContainer.addSubview(locationView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: locationView, in: locationInputContainer))
    }

    // MARK: - Drafts

    @objc private func saveDraftAndTrack() {
        saveDraft(track: true)
    }

    private func saveDraft(track: Bool) {
        let coordinate = input.locationInfo()
        var files: [AutoPhotoAttachmentDraft] = []
        let steps = photoGroups.flatMap { $0.steps }
        for step in steps {
            let photos: [Attachment] = step.attachments.filter { attachmentService.attachmentExists($0) }
            let attachments: [AutoPhotoAttachmentDraft] = photos.map {
                AutoPhotoAttachmentDraft(filename: $0.filename, fileType: step.fileType, photoStepId: step.stepId)
            }
            files.append(contentsOf: attachments)
        }
        let id = input.draft?.id ?? UUID().uuidString
        let draft = AutoEventDraft(
			id: id,
			insuranceId: model.insurance.id,
			claimDate: model.date,
			fullDescription: model.causes,
			files: files,
			coordinate: coordinate.position,
			lastModify: Date(),
			caseType: input.caseType
		)
        if track {
            analytics.track(event: AnalyticsEvent.Auto.reportAutoSaveDraft)
        }
        output.saveDraft(draft)
    }

    private func loadDraft(_ draft: AutoEventDraft) {
        model.causes = draft.fullDescription
        model.date = draft.claimDate
        for file in draft.files {
            let attachments: [Attachment] = [ attachmentService.loadAttachmentFromDraft(file) ].compactMap { $0 }

            photoGroups.forEach { $0.add(attachments: attachments, stepId: file.photoStepId) }
        }
        updateUI()

        // Load location info
        draft.coordinate.map(output.loadLocation)
    }

    // MARK: - @IBAction

    @IBAction private func toggleSelectDateView(_ sender: UITapGestureRecognizer) {
        if sender === selectDateTap {
            guard !stackView.arrangedSubviews.contains(selectDateView) else {
                hidePickers()
                return
            }

            if stackView.arrangedSubviews.contains(selectTimeView) {
                hidePickers()
            }

            guard let index = stackView.arrangedSubviews.firstIndex(of: accidentDateParentContainerView) else { return }

            if let date = model.date {
                selectDateView.set(date: date)
            }

            view.endEditing(true)
            stackView.insertArrangedSubview(selectDateView, at: index + 1)

            var rect = selectDateView.frame
            rect.origin = CGPoint(x: accidentDateParentContainerView.frame.origin.x, y: accidentDateParentContainerView.frame.maxY)
            rect.size.height += 60
            scrollView.scrollRectToVisible(rect, animated: true)
        } else if sender === selectTimeTap {
            guard !stackView.arrangedSubviews.contains(selectTimeView) else {
                hidePickers()
                return
            }

            if stackView.arrangedSubviews.contains(selectDateView) {
                hidePickers()
            }

            guard let index = stackView.arrangedSubviews.firstIndex(of: accidentDateParentContainerView) else { return }

            if let date = model.date {
                selectTimeView.set(date: date)
            }

            view.endEditing(true)
            stackView.insertArrangedSubview(selectTimeView, at: index + 1)

            var rect = selectTimeView.frame
            rect.origin = CGPoint(x: accidentDateParentContainerView.frame.origin.x, y: accidentDateParentContainerView.frame.maxY)
            rect.size.height += 60
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

    @IBAction private func sendCase() {
        if input.isDemo {
			DemoBottomSheet.presentInfoDemoSheet(from: self)
            return
        }

        guard
            formIsReady(),
            let date = model.date,
            let coordinate = model.locationInfo.position
        else { return }

        // Ensure to count only photos that are present on disk
        let documentsCount = photoGroups
            .flatMap { $0.photos }
            .filter { attachmentService.attachmentExists($0) }
            .count
        sendButton.isEnabled = false
        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        let event = CreateAutoEventReport(
            insuranceId: model.insurance.id,
            fullDescription: model.causes,
            coordinate: coordinate,
            documentCount: documentsCount,
            claimDate: date,
            timezone: date,
            geoPlace: model.locationInfo.place
        )
        output.createEvent(event, input.draft != nil) { [weak self] in
            hide(nil)
            self?.sendButton.isEnabled = true
        }
    }

    @IBAction private func backAction() {
        view.endEditing(false)

        let message = "Завершить создание страхового случая?"
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let closeAction = UIAlertAction(title: NSLocalizedString("common_end", comment: ""), style: .default) { _ in
            self.analytics.track(event: AnalyticsEvent.Auto.reportAutoExitDeleteDraft)
            self.output.goBack()
        }
        alert.addAction(closeAction)
        let saveAction = UIAlertAction(title: NSLocalizedString("common_save_draft", comment: ""), style: .default) { _ in
            self.analytics.track(event: AnalyticsEvent.Auto.reportAutoExitSaveDraft)
            self.saveDraft(track: false)
            self.output.goBack()
        }
        alert.addAction(saveAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel) { _ in
            self.analytics.track(event: AnalyticsEvent.Auto.reportAutoExitCancel)
        }
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    @IBAction private func placePhotoTap() {
        guard let photoGroup = photoGroups.first(where: { $0.type == .place }) else { return }

        output.photoGroup(photoGroup)
    }

    @IBAction private func planPhotoTap() {
        guard let photoGroup = photoGroups.first(where: { $0.type == .plan }) else { return }

        output.photoGroup(photoGroup)
    }

    @IBAction private func damagePhotoTap() {
        guard let photoGroup = photoGroups.first(where: { $0.type == .damage }) else { return }

        output.photoGroup(photoGroup)
    }

    @IBAction private func vinPhotoTap() {
        guard let photoGroup = photoGroups.first(where: { $0.type == .vin }) else { return }

        output.photoGroup(photoGroup)
    }

    @IBAction private func docsPhotoTap() {
        guard let photoGroup = photoGroups.first(where: { $0.type == .docs }) else { return }

        output.photoGroup(photoGroup)
    }

    private func hidePickers() {
        stackView.removeArrangedSubview(selectTimeView)
        selectTimeView.removeFromSuperview()
        stackView.removeArrangedSubview(selectDateView)
        selectDateView.removeFromSuperview()
    }

    // MARK: Types

    private struct FormModel {
        var insurance: Insurance
        var locationInfo: LocationInfo
        var causes: String
        var date: Date?

        var isReady: Bool {
            let coordinatesReady = locationInfo.position != nil
            let causesReady = !(causes.isEmpty)
            let dateReady = date != nil
            return [ coordinatesReady, causesReady, dateReady ].allSatisfy { $0 }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		sendButton <~ Style.RoundedButton.redBackground
	}
}
