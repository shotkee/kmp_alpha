//
//  MainNotifyItemView.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 14/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class MainNotifyItemView: UIView {
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var mainTextLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    private var item: HomeModel.NotificationItem!
    private var output: Output!

    @IBAction private func actionClick(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.superview?.isHidden = true
        }
        output.tapAction(item)
    }

    @IBAction private func onViewClick(_ sender: Any) {
        output.tapView(item)
    }

    func set(item: HomeModel.NotificationItem, output: Output) {
        self.item = item
        self.output = output
        setupUI()
    }

    struct Output {
        let tapAction: (HomeModel.NotificationItem) -> Void
        let tapView: (HomeModel.NotificationItem) -> Void
    }

    private func setupUI() {
        guard let item = self.item else { return }

        switch item {
            case .alphaPoint:
                titleLabel.text = NSLocalizedString("alphaPoint", comment: "")
                mainTextLabel.text = NSLocalizedString("alphaPoint_notification_text", comment: "")
                subTitleLabel.text = stringFromDate(Date())
                actionButton.setImage(ButtonImage.cross.image, for: .normal)
            case .notification(let appNotification):
                // TODO: Temporary, Get it from back later
                titleLabel.text = "Категория"
                mainTextLabel.text = appNotification.title
                subTitleLabel.text = stringFromDate(appNotification.date)
                actionButton.setImage(ButtonImage.cross.image, for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.secondaryCaption1
        mainTextLabel <~ Style.Label.primaryText
        subTitleLabel <~ Style.Label.secondaryCaption1
    }

    private func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLocale.currentLocale
        formatter.dateFormat = "dd MMMM в HH:mm"
        return formatter.string(from: date)
    }

    private enum ButtonImage: String {
        case cross = "ico-close"
        case arrow = "ico-arrow"

        var image: UIImage? {
            UIImage(named: self.rawValue)
        }
    }
}
