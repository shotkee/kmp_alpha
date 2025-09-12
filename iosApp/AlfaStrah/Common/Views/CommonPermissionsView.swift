//
//  CommonPermissionsView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class CommonPermissionsView: UIView {
    struct PermissionCardInfo {
        let icon: UIImage?
        let title: String
        let text: String

        static let euroProtocolPermissions: [PermissionCardInfo] = [
            .init(
                icon: UIImage(named: "icon-europrotocol-location"),
                title: NSLocalizedString("euro_protocol_geolocation_access_title", comment: ""),
                text: NSLocalizedString("euro_protocol_geolocation_access_text", comment: "")
            ),
            .init(
                icon: UIImage(named: "icon-europrotocol-photo"),
                title: NSLocalizedString("euro_protocol_camera_access_title", comment: ""),
                text: NSLocalizedString("euro_protocol_camera_access_text", comment: "")
            ),
            .init(
                icon: UIImage(named: "icon-europrotocol-phone"),
                title: NSLocalizedString("euro_protocol_storage_access_title", comment: ""),
                text: NSLocalizedString("euro_protocol_storage_access_text", comment: "")
            )
        ]
    }

    var openSettingsAction: (() -> Void)?

    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var actionButton: RoundEdgeButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        rootStackView.spacing = 27
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(NSLocalizedString("common_open_settings", comment: ""), for: .normal)
    }

    func set(cards: [PermissionCardInfo]) {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var infoViews: [UIView] = []
        for cardInfo in cards {
            infoViews.append(
                infoView(
                    icon: cardInfo.icon,
                    title: cardInfo.title,
                    text: cardInfo.text
                )
            )
        }

        infoViews.forEach { rootStackView.addArrangedSubview($0) }
    }

    private func infoView(icon: UIImage?, title: String, text: String) -> UIView {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 12

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .leading
        verticalStack.addArrangedSubview(horizontalStack)

        let iconImageView = UIImageView()
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.image = icon
        horizontalStack.addArrangedSubview(iconImageView)

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryHeadline3
        titleLabel.text = title
        horizontalStack.addArrangedSubview(titleLabel)

        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel <~ Style.Label.secondaryText
        textLabel.text = text
        verticalStack.addArrangedSubview(textLabel)

        return verticalStack
    }

    @IBAction private func settingsTap() {
        openSettingsAction?()
    }
}
