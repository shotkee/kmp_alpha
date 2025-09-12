//
//  RegistrationAccidentViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AutoEventRegistrationAccidentViewController: ViewController {
    enum CardViewType: CaseIterable {
        case drawUpEuroProtocol
        case paperEuroProtocol

        var title: String {
            switch self {
                case .drawUpEuroProtocol:
                    return NSLocalizedString("insurance_euro_protocol_accident_protocol_title", comment: "")
                case .paperEuroProtocol:
                    return NSLocalizedString("insurance_euro_protocol_accident_statement_title", comment: "")
            }
        }

        var detail: String {
            switch self {
                case .drawUpEuroProtocol:
                    return NSLocalizedString("insurance_euro_protocol_accident_detail", comment: "")
                case .paperEuroProtocol:
                    return NSLocalizedString("insurance_euro_protocol_registration_detail", comment: "")
            }
        }
    }

    private lazy var rootScrollView: UIScrollView = .init(frame: .zero)
    private lazy var rootView: UIView = .init(frame: .zero)

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 20

        return stack
    }()

    struct Output {
        let drawUpEuroProtocolTap: () -> Void
        let paperEuroProtocolTap: () -> Void
    }

    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(rootScrollView)

        rootScrollView.addSubview(rootView)
        rootView.addSubview(contentStackView)

        rootScrollView.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            rootScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootScrollView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            rootView.topAnchor.constraint(equalTo: rootScrollView.topAnchor, constant: 24),
            rootView.bottomAnchor.constraint(equalTo: rootScrollView.bottomAnchor),
            rootView.trailingAnchor.constraint(equalTo: rootScrollView.trailingAnchor),
            rootView.leadingAnchor.constraint(equalTo: rootScrollView.leadingAnchor),
            rootView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            contentStackView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 18)
        ])
    }

    private func setupUI() {
        title = NSLocalizedString("auto_event_case_accident_osago_no_gibdd_title", comment: "")
		view.backgroundColor = .Background.backgroundContent

        CardViewType.allCases.forEach { contentStackView.addArrangedSubview(self.createCardView($0)) }
    }

    private func createCardView(_ type: CardViewType) -> CardView {
        let infoView: CommonNoteLabelView = .init()

        infoView.set(
            title: type.title,
            note: type.detail,
            style: .center(UIImage(named: "right_arrow_icon_gray")),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            appearance: .regularTitle
        )

        infoView.tapHandler = { [weak self] in
            guard let `self` = self else { return }

            switch type {
                case .drawUpEuroProtocol:
                    self.output.drawUpEuroProtocolTap()
                case .paperEuroProtocol:
                    self.output.paperEuroProtocolTap()
            }
        }
		
		let cardView = CardView(contentView: infoView)
		cardView.contentColor = .Background.backgroundSecondary

        return cardView
    }
}
