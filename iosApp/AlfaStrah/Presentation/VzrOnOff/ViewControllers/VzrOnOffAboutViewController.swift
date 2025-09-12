//
//  VzrOnOffAboutViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffAboutViewController: ViewController {
    private enum Constants {
        struct InfoItem {
            let image: UIImage?
            let text: String
        }

        static let info: [InfoItem] = [
            .init(image: UIImage(named: "icon-vzr-on-off-plane"), text: NSLocalizedString("vzr_about_plane_text", comment: "")),
            .init(image: UIImage(named: "icon-vzr-on-off-calendar"), text: NSLocalizedString("vzr_about_calendar_text", comment: "")),
            .init(image: UIImage(named: "icon-vzr-on-off-phone"), text: NSLocalizedString("vzr_about_phone_text", comment: "")),
            .init(image: UIImage(named: "icon-vzr-on-off-man"), text: NSLocalizedString("vzr_about_man_text", comment: ""))
        ]
        static let defaultInset: CGFloat = 18
    }

    struct Input {
        let landingUrl: (@escaping (Result<String, AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let details: (URL) -> Void
        let buyPolicy: () -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var detailsButton: RoundEdgeButton!
    @IBOutlet private var purchaseButton: RoundEdgeButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var buttonsStackView: UIStackView!
    private var detailsUrlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_about_program_title", comment: "")
        addZeroView()
        Constants.info.forEach { item in
            let itemView: VzrOnOffAboutProgramView = .fromNib()
            itemView.configure(with: item.image, text: item.text)
            stackView.addArrangedSubview(itemView)
        }
        detailsButton <~ Style.RoundedButton.redBordered
        detailsButton.setTitle(NSLocalizedString("vzr_about_more_info", comment: ""), for: .normal)
        purchaseButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        purchaseButton.setTitle(NSLocalizedString("insurance_buy", comment: ""), for: .normal)
        scrollView.contentInset.bottom = Constants.defaultInset
        scrollView.scrollIndicatorInsets.bottom = Constants.defaultInset
        refresh()
    }

    private func refresh() {
        showZeroView()
        zeroView?.update(viewModel: .init(kind: .loading))
        input.landingUrl { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let urlString):
                    self.hideZeroView()
                    self.detailsUrlString = urlString
                case .failure(let error):
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.refresh() }))
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }

    @IBAction private func detailsTap(_ sender: UIButton) {
        guard
            let detailsUrlString = detailsUrlString,
            let url = URL(string: detailsUrlString)
        else {
            ErrorHelper.show(
                error: nil,
                text: NSLocalizedString("vzr_about_program_url_is_unavailable", comment: ""),
                alertPresenter: self.alertPresenter
            )
            return
        }

        output.details(url)
    }

    @IBAction private func purchaseTap(_ sender: UIButton) {
        output.buyPolicy()
    }
}
