//
//  ActiveEventsViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 23/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ActiveEventsViewController: ViewController {
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var sosButton: RoundEdgeButton!
    typealias EventReportKind = InsuranceEventFlow.EventReportKind
    typealias DraftKind = InsuranceEventFlow.DraftKind

    struct EventSection {
        var insurance: Insurance
        var events: [EventReportKind]
    }
    private var sections: [EventSection] = [] {
        didSet {
            createCardView()
        }
    }

    struct Input {
        var data: (_ completion: @escaping (Result<[EventSection], AlfastrahError>) -> Void) -> Void
        var draft: (Insurance) -> DraftKind?
    }

    struct Output {
        var selectEvent: (EventReportKind, Insurance) -> Void
        var selectDraft: (DraftKind, Insurance) -> Void
        var createEvent: ([Insurance]) -> Void
    }

    struct Notify {
        var draftUpdated: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        draftUpdated: { [weak self] in
            guard let self = self else { return }

            self.update()
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		sosButton <~ Style.RoundedButton.redBackground
		
        title = ""
        addZeroView()
        update()
    }

    @IBAction private func sosTap(_ sender: Any) {
        output.createEvent(sections.map { $0.insurance })
    }

    private func titleFor(insurance: Insurance) -> String {
        switch insurance.type {
            case .kasko:
                return NSLocalizedString("auto_insurance", comment: "")
            case .osago:
                return NSLocalizedString("auto_osago_insurance", comment: "")
            case .dms, .life, .passengers, .property, .vzr, .vzrOnOff, .accident, .flatOnOff, .unknown:
                return ""
        }
    }

    private func createCardView() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        let type = sections.map { $0.insurance }.first?.insuranceEventKind

        if case .some(.passengers) = type {
            title = NSLocalizedString("drafts", comment: "")
        } else {
            title = NSLocalizedString("active_events", comment: "")
        }
        guard !(sections.flatMap { $0.events }.isEmpty && sections.compactMap { input.draft($0.insurance) }.isEmpty) else {
            let zeroViewModel = ZeroViewModel(kind: .emptyList)
            zeroView?.update(viewModel: zeroViewModel)
            showZeroView()
            view.bringSubviewToFront(sosButton)
            return
        }

        for section in sections {
            let eventsStackView = UIStackView()
            eventsStackView.axis = .vertical
            eventsStackView.spacing = 18.0

            if let draft = input.draft(section.insurance) {
                hideZeroView()
                let eventView = EventView.fromNib()
                switch draft {
                    case .autoDraft:
                        eventView.set(
                            title: NSLocalizedString("main_banner_draft_kasko", comment: ""),
                            subtitle: NSLocalizedString("main_request_not_complete", comment: ""),
                            color: .Text.textAccent,
                            eventNumber: "",
                            action: { [weak self] in
                                self?.output.selectDraft(draft, section.insurance)
                            }
                        )
                    case .passengerDraft:
                        eventView.set(
                            title: NSLocalizedString("draft_title", comment: ""),
                            subtitle: NSLocalizedString("main_request_not_complete", comment: ""),
							color: .Text.textAccent,
                            eventNumber: "",
                            action: { [weak self] in
                                self?.output.selectDraft(draft, section.insurance)
                            }
                        )
                }
                eventsStackView.addArrangedSubview(CardView(contentView: eventView))
            }
            for event in section.events {
                let eventView = EventView.fromNib()
                let title: String
                let subtitle: String
                switch event {
                    case .auto(let event):
                        title = NSLocalizedString("auto_draft_title", comment: "") + ", " + AppLocale.dateString(event.createDate)
                        subtitle = event.currentStatus?.title ?? NSLocalizedString("main_request_complete", comment: "")
                    case .passenger:
                        title = NSLocalizedString("insurance_case", comment: "")
                        subtitle = NSLocalizedString("main_request_complete", comment: "")
                    case .accident(let event):
                        title = NSLocalizedString("insurance_event_accident_title", comment: "")
                        subtitle = event.status
                }
                // swiftlint:disable:next trailing_closure
                eventView.set(
                    title: title,
                    subtitle: subtitle,
					color: .Text.textSecondary,
                    eventNumber: event.eventNumber,
                    action: { [weak self] in
                        self?.output.selectEvent(event, section.insurance)
                    }
                )
                eventsStackView.addArrangedSubview(CardView(contentView: eventView))
            }
            if !eventsStackView.arrangedSubviews.isEmpty {
                let label = UILabel()
                label <~ Style.Label.primaryHeadline1
                label.text = titleFor(insurance: section.insurance)
                label.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(label)
                NSLayoutConstraint.activate([
                    label.heightAnchor.constraint(equalToConstant: 46.0)
                ])
                stackView.addArrangedSubview(eventsStackView)
            }
        }
    }

    private func addCardView(with view: UIView) -> UIView {
        let cardView = CardView(contentView: view)
		cardView.contentColor = .Background.backgroundSecondary
        return cardView
    }

    private func update() {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.data { [weak self] response in
            guard let self = self else { return }

            switch response {
                case .success(let sections):
                    self.hideZeroView()
                    self.sections = sections
                case .failure(let error):
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.update() }))
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
                    self.showZeroView()
                    self.processError(error)
            }
        }
    }
}
