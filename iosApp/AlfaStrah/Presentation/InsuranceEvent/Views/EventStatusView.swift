//
//  EventStatusView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

class EventStatusView: UIView, ImageLoaderDependency {
    @IBOutlet private var indicatorView: EventStatusIndicatorView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var stoaContainer: UIView!
    @IBOutlet private var decisionContainer: UIView!

    var imageLoader: ImageLoader! {
        didSet {
            indicatorView.imageLoader = imageLoader
        }
    }

    var isFirstItem = false {
        didSet { indicatorView.isFirstItem = isFirstItem }
    }

    var isLastItem = false {
        didSet { indicatorView.isLastItem = isLastItem }
    }

    struct Output {
        var routeTap: (CLLocationCoordinate2D, _ title: String?) -> Void
        var phoneTap: (Phone) -> Void
        var decisionTap: (URL) -> Void
    }

    var output: Output!

    override func awakeFromNib() {
        super.awakeFromNib()

		backgroundColor = .Background.backgroundSecondary
		indicatorView.backgroundColor = .Background.backgroundSecondary
		decisionContainer.backgroundColor = .Background.backgroundSecondary
		stoaContainer.backgroundColor = .Background.backgroundSecondary
        titleLabel <~ Style.Label.primaryHeadline2
        descriptionLabel <~ Style.Label.secondaryHeadline2
        dateLabel <~ Style.Label.secondaryHeadline2
    }

    func set(_ eventStatus: EventStatus, output: Output) {
        self.output = output
        indicatorView.active = eventStatus.passed
        titleLabel.text = eventStatus.title
        descriptionLabel.text = eventStatus.shortDescription
        dateLabel.text = eventStatus.date.map(AppLocale.dateString)

        if let decision = eventStatus.decision {
            configureViewForDecision(decision)
        }

        if let stoa = eventStatus.stoa {
            configureStoaViewForStoa(stoa)
        }

        indicatorView.iconImageUrl = eventStatus.imageUrl
    }

    private func configureViewForDecision(_ decision: EventDecision) {
        let decisionView = EventDecisionView()
        decisionView.set(eventDecision: decision, decisionTapHandler: output.decisionTap)
        decisionView.translatesAutoresizingMaskIntoConstraints = false
        decisionContainer.addSubview(decisionView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: decisionView, in: decisionContainer))
    }

    private func configureStoaViewForStoa(_ stoa: Stoa) {
        let stoaView = EventStoaView()
        stoaView.set(stoa: stoa, routeTapHandler: output.routeTap, phoneTapHandler: output.phoneTap)
        stoaView.translatesAutoresizingMaskIntoConstraints = false
        stoaContainer.addSubview(stoaView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stoaView, in: stoaContainer))
    }
}
