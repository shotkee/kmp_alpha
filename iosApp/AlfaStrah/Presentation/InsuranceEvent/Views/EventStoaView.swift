//
//  EventStoaView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import CoreLocation

class EventStoaView: UIView {
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: Style.Margins.defaultInsets.top, left: 0, bottom: 0, right: 0)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stackView, in: self))
    }

    func set(
        stoa: Stoa,
        routeTapHandler: @escaping (CLLocationCoordinate2D, _ title: String?) -> Void,
        phoneTapHandler: @escaping (Phone) -> Void
    ) {
        let mapView = MapInfoView.fromNib()
        mapView.configureForCoordinate(stoa.coordinate.clLocationCoordinate)
        stackView.addArrangedSubview(mapView)

        if let address = stoa.address {
            let addressInfoView = CommonInfoView.fromNib()
            addressInfoView.set(title: nil, textBlocks: [ CommonInfoView.TextBlock(text: address) ])
            stackView.addArrangedSubview(addressInfoView)
        }

        let workHoursInfoView = CommonInfoView.fromNib()
        workHoursInfoView.set(title: NSLocalizedString("info_open_hours", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: stoa.serviceHours) ])
        stackView.addArrangedSubview(workHoursInfoView)

        let routeInfoView = CommonInfoView.fromNib()
        let textBlock = CommonInfoView.TextBlock(text: NSLocalizedString("info_get_route", comment: "")) {
            routeTapHandler(stoa.coordinate.clLocationCoordinate, stoa.address)
        }
        routeInfoView.set(title: nil, textBlocks: [ textBlock ], icon: UIImage(named: "icon-route"))
        stackView.addArrangedSubview(routeInfoView)

        if !stoa.phoneList.isEmpty {
            let textBlocks = stoa.phoneList.map { phone in
                CommonInfoView.TextBlock(text: phone.humanReadable) {
                    phoneTapHandler(phone)
                }
            }
            let phoneInfoView = CommonInfoView.fromNib()
            phoneInfoView.set(title: NSLocalizedString("info_phone", comment: ""), textBlocks: textBlocks,
                icon: UIImage(named: "icon-phone"))
            stackView.addArrangedSubview(phoneInfoView)
        }
    }

    private func infoStackView(title: String, subtitle: String?) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.secondaryText
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)

        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel <~ Style.Label.primaryText
            subtitleLabel.text = subtitle
            stackView.addArrangedSubview(subtitleLabel)
        }

        return stackView
    }
}
