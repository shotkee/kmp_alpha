//
//  InsuranceEventReportViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import CoreLocation
import TinyConstraints

class InsuranceEventReportViewController: ViewController,
										  AttachmentServiceDependency {
    typealias EventReportKind = InsuranceEventFlow.EventReportKind

    struct Input {
        var eventReport: EventReportKind
        var insurance: Insurance
    }

    struct Output {
        var routeTap: (CLLocationCoordinate2D, _ title: String?) -> Void
        var phoneTap: (Phone) -> Void
        var decisionTap: (URL) -> Void
        var showChat: () -> Void
        var addPhoto: () -> Void
		var onOpenWeb: (URL) -> Void
    }

    var input: Input!
    var output: Output!
    var attachmentService: AttachmentService!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var addPhotoButton: RoundEdgeButton!
    @IBOutlet private var buttonHeightConstraint: NSLayoutConstraint!
    private var attachmentsInfoView: CommonInfoView?

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        setup()
        subscribeToUploads()
    }

    // MARK: - Setup UI

    private func setup() {
        switch input.eventReport {
            case .auto:
                title = NSLocalizedString("insurance_event_auto_type_title", comment: "")
            case .accident:
                title = NSLocalizedString("insurance_event_accident_type_title", comment: "")
            case .passenger:
                title = NSLocalizedString("insurance_event_passenger_type_title", comment: "")
        }
        stackView.subviews.forEach { $0.removeFromSuperview() }

        switch input.eventReport {
            case .passenger(let eventReport):
                configure(passengerEvent: eventReport)
            case .auto(let eventReport):
                configure(autoEvent: eventReport)
            case .accident:
                break
        }
    }

    private func configure(passengerEvent event: EventReport) {
        buttonHeightConstraint.constant = 0
        addPhotoButton.isHidden = true

        let insuranceInfoView = CommonInsuranceInfoTitleView.fromNib()
        insuranceInfoView.set(title: input.insurance.title, subtitle: input.insurance.insuredObjectTitle)
        stackView.addArrangedSubview(insuranceInfoView)

        let insuranceTypeInfoView = CommonInfoView.fromNib()
        insuranceTypeInfoView.set(
            title: NSLocalizedString("insurance_event_type_title", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: event.eventType.title) ],
            appearance: .newRegular
        )
        stackView.addArrangedSubview(insuranceTypeInfoView)

        if !event.number.isEmpty {
            let eventNumberInfoView = CommonInfoView.fromNib()
            eventNumberInfoView.set(
                title: NSLocalizedString("insurance_event_number_title", comment: ""),
                textBlocks: [ CommonInfoView.TextBlock(text: event.number) ],
                appearance: .newRegular
            )
            stackView.addArrangedSubview(eventNumberInfoView)
        }

        if let coordinate = event.coordinate {
            let mapView = MapInfoView.fromNib()
            mapView.configureForCoordinate(coordinate.clLocationCoordinate)
            stackView.addArrangedSubview(mapView)
        }

        let createDateInfoView = CommonInfoView.fromNib()
        createDateInfoView.set(
            title: NSLocalizedString("insurance_event_create_date_title", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: AppLocale.dateString(event.createDate)) ],
            appearance: .newRegular
        )
        stackView.addArrangedSubview(createDateInfoView)

        let sentDateInfoView = CommonInfoView.fromNib()
        sentDateInfoView.set(
            title: NSLocalizedString("insurance_event_sent_date_title", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: AppLocale.dateString(event.sentDate)) ],
            appearance: .newRegular
        )
        stackView.addArrangedSubview(sentDateInfoView)
    }

    private func configure(autoEvent event: EventReportAuto) {
        addPhotoButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        addPhotoButton.setTitle(NSLocalizedString("common_add_photo", comment: ""), for: .normal)
        buttonHeightConstraint.constant = 51
        addPhotoButton.isHidden = false

        let insuranceInfoView = CommonInsuranceInfoTitleView.fromNib()
        insuranceInfoView.set(title: input.insurance.title, subtitle: input.insurance.insuredObjectTitle)
        stackView.addArrangedSubview(insuranceInfoView)

        let insuranceTypeInfoView = CommonInfoView.fromNib()
        insuranceTypeInfoView.set(
            title: NSLocalizedString("insurance_event_type_title", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: event.eventType.title) ],
            appearance: .newRegular
        )
        stackView.addArrangedSubview(insuranceTypeInfoView)

        if event.coordinate != nil || event.address != nil {
            let mapView = EventLocationView.fromNib()
            mapView.configure(coordinate: event.coordinate?.clLocationCoordinate, address: event.address)
            stackView.addArrangedSubview(mapView)
        }

        if !event.statuses.isEmpty {
            let statusHeaderView = EventStatusHeaderView()
            statusHeaderView.actionTapHandler = { [weak self] in
                guard let self = self else { return }

                self.output.showChat()
            }
            stackView.addArrangedSubview(statusHeaderView)
        }

        for (index, status) in event.statuses.enumerated() {
            let statusView = EventStatusView.fromNib()
            container?.resolve(statusView)
            statusView.set(status, output: .init(
                routeTap: output.routeTap,
                phoneTap: output.phoneTap,
                decisionTap: { [weak self] url in
                    guard let self = self else { return }

                    self.output.decisionTap(url)
                })
            )
            statusView.isFirstItem = index == 0
            statusView.isLastItem = index == event.statuses.count - 1
            stackView.addArrangedSubview(statusView)
        }
		
		if !event.documents.isEmpty
		{
			addDocumentsView(documents: event.documents)
		}
		
        updateAttachmentsInfoView()
    }
	
	private func addDocumentsView(documents: [EventReportAutoDocument])
	{
		func createTitleView() -> UIView
		{
			let view = UIView()
			view.backgroundColor = .clear
			
			let titleLabel = UILabel()
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.numberOfLines = 1
			titleLabel.text = NSLocalizedString("document_title", comment: "")
			
			view.addSubview(titleLabel)
			titleLabel.edgesToSuperview(
				insets: .init(
					top: 24,
					left: 16,
					bottom: 8,
					right: 16
				)
			)
			
			return view
		}
		
		let documentsStackView = UIStackView()
		documentsStackView.axis = .vertical
		
		documentsStackView.addArrangedSubview(createTitleView())
		
		for (index, document) in documents.enumerated()
		{
			documentsStackView.addArrangedSubview(
				createDocumentView(
					index: index,
					document: document
				)
			)
		}
		
		stackView.addArrangedSubview(documentsStackView)
	}
	
	private func createDocumentView(index: Int, document: EventReportAutoDocument) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		view.tag = index
		
		let tagView = createTagView()
		view.addSubview(tagView)
		tagView.topToSuperview(
			offset: 21
		)
		tagView.leadingToSuperview(offset: 16)
		
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryHeadline2
		titleLabel.numberOfLines = 0
		titleLabel.text = document.title
		
		view.addSubview(titleLabel)
		titleLabel.verticalToSuperview(
			insets: .vertical(19)
		)
		titleLabel.trailingToSuperview(offset: 16)
		titleLabel.leadingToTrailing(
			of: tagView,
			offset: 8
		)
		
		let spacerView = UIView()
		spacerView.backgroundColor = .Stroke.divider
		spacerView.height(1)
		view.addSubview(spacerView)
		spacerView.horizontalToSuperview(insets: .horizontal(16))
		spacerView.bottomToSuperview()
		
		let tap = UITapGestureRecognizer(
			target: self,
			action: #selector(onTap)
		)
		
		view.addGestureRecognizer(tap)
		
		return view
	}
	
	private func createTagView() -> UIView
	{
		let view = UIView()
		view.backgroundColor = UIColor.Background.backgroundAccent
		view.height(19)
		view.clipsToBounds = true
		view.layer.cornerRadius = 4
		
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.contrastText2
		titleLabel.text = "PDF"
		titleLabel.textAlignment = .center
		
		view.addSubview(titleLabel)
		titleLabel.edgesToSuperview(
			insets: .init(
				top: 2,
				left: 4,
				bottom: 2,
				right: 4
			)
		)
		
		return view
	}
	
	@objc private func onTap(sender: UITapGestureRecognizer)
	{
		var documents: [EventReportAutoDocument] = []
		
		switch input.eventReport 
		{
			case .passenger, .accident:
				break
			case .auto(let eventReport):
				documents = eventReport.documents
		}
		
		guard let tag = sender.view?.tag,
			  let url = documents[safe: tag]?.url
		else { return }
		
		output.onOpenWeb(url)
	}
	

    private func updateAttachmentsInfoView() {
        if let status = attachmentService.uploadStatus(eventReportId: input.eventReport.eventId),
                status.uploadedDocumentsCount != status.totalDocumentsCount {
            let attachmentsInfoView = self.attachmentsInfoView ?? CommonInfoView.fromNib()
            self.attachmentsInfoView = attachmentsInfoView
            let statusText = String(
                format: NSLocalizedString("photos_upload_status_value", comment: ""),
                "\(status.uploadedDocumentsCount)", "\(status.totalDocumentsCount)"
            )
            attachmentsInfoView.set(title: NSLocalizedString("common_photos", comment: ""),
                textBlocks: [ CommonInfoView.TextBlock(text: statusText) ])
            if !stackView.arrangedSubviews.contains(attachmentsInfoView) {
                stackView.addArrangedSubview(attachmentsInfoView)
            }
        } else {
            attachmentsInfoView.map { $0.removeFromSuperview() }
            attachmentsInfoView = nil
        }
    }

    private func subscribeToUploads() {
        attachmentService.subscribeToUploads { [weak self] in
            self?.updateAttachmentsInfoView()
        }.disposed(by: disposeBag)
    }

    @IBAction func addPhotoTap(_ sender: UIButton) {
        if case .auto = input.eventReport {
            analytics.track(event: AnalyticsEvent.Auto.reportAutoStatusAdd)
        }
        output.addPhoto()
    }
}
