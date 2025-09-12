//
// NotificationInfoViewController
// AlfaStrah
//
// Created by Eugene Egorov on 02 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import MapKit
import Legacy

class NotificationInfoViewController: ViewController {
    private struct Field {
        var title: String?
        var subtitle: String?
    }
    
    struct Input {
        var notification: AppNotification
        var insurance: Insurance?
    }

    struct Output {
        var action: (AppNotification) -> Void
    }

    var input: Input!
    var output: Output!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButton = RoundEdgeButton()
    private let actionButtonsStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("notifications_info_title", comment: "")
        view.backgroundColor = Style.Color.background
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupActionButton()
        
        update()
    }

    @IBAction private func actionButtonTap(_ sender: UIButton) {
        output.action(input.notification)
    }

    private func update() {
        let notification = input.notification
        
        switch notification.type {
            case .message, .realtyRenew:
                setupMessage(notification: notification)
                actionButton.setTitle(
                    NSLocalizedString("common_goto_insurance", comment: ""),
                    for: .normal
                )
                actionButtonsStackView.isHidden = false
            case .newsNotification:
                switch notification.target {
                    case .alfaPoints:
                        actionButton.setTitle(
                            NSLocalizedString("common_go_to_alfapoints", comment: ""),
                            for: .normal
                        )
                        actionButtonsStackView.isHidden = false
                    case .externalUrl:
                        if notification.url != nil {
                            actionButton.setTitle(
                                NSLocalizedString("common_open_url", comment: ""),
                                for: .normal
                            )
                            actionButtonsStackView.isHidden = false
                        }
                    case .mainScreen, .insurancesList, .telemedecide, .kaskoProlongation, .unsupported:
                        actionButton.setTitle(
                            NSLocalizedString("common_goto_insurance", comment: ""),
                            for: .normal
                        )
                        actionButtonsStackView.isHidden = false
                }
                
                setupMessage(notification: notification)
            case .fieldList:
                setupFieldList(notification: notification)
                actionButton.setTitle(
                    NSLocalizedString("common_goto_insurance", comment: ""),
                    for: .normal
                )
                actionButtonsStackView.isHidden = false
            case .stoa:
                setupStoa(notification: notification)
                actionButton.setTitle(
                    NSLocalizedString("common_goto_insurance", comment: ""),
                    for: .normal
                )
                actionButtonsStackView.isHidden = false
            default:
                break
        }
    }
    
    private func setupActionButton() {
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(actionButton)
        
        actionButtonsStackView.isHidden = true
    }

    private func setupMessage(notification: AppNotification) {
        let view = NotificationInfoMessageView()
        view.set(date: notification.date, title: notification.title, content: notification.fullText)
        contentStackView.addArrangedSubview(view)
    }

    private func setupFieldList(notification: AppNotification) {
        let titleView = NotificationInfoTitleView.fromNib()
        titleView.set(title: notification.title)
        contentStackView.addArrangedSubview(titleView)

        let fields: [Field] = (notification.fieldList ?? [])
            .map { field in
                Field(title: field.title, subtitle: field.value)
            }
            .filter {
                !($0.title == nil && $0.subtitle != nil)
            }
        let fieldsViews: [UIView] = fields.map {
            let view = NotificationInfoFieldView.fromNib()
            view.set(title: $0.title, subtitle: $0.subtitle)
            return view
        }
        fieldsViews.forEach(contentStackView.addArrangedSubview)
    }

    private func setupStoa(notification: AppNotification) {
        let titleView = NotificationInfoTitleView.fromNib()
        titleView.set(title: notification.title)
        contentStackView.addArrangedSubview(titleView)

        if let stoa = notification.stoa {
            let location = stoa.coordinate.clLocation
            let addressView = NotificationInfoAddressView.fromNib()
            addressView.set(name: stoa.title, address: stoa.address, serviceHours: stoa.serviceHours, location: location)
            contentStackView.addArrangedSubview(addressView)

            let routeView = NotificationInfoActionView.fromNib()
            routeView.set(
                title: NSLocalizedString("notifications_info_route", comment: ""),
                subtitle: "",
                icon: UIImage(named: "ico-addf-route")
            ) {
                let placemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = stoa.title
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
            contentStackView.addArrangedSubview(routeView)

            if let phone = stoa.phoneList.first {
                let phoneImage = UIImage(named: "ico-addf-tel")
                let phoneView = NotificationInfoActionView.fromNib()
                phoneView.set(
                    title: phone.humanReadable,
                    subtitle: NSLocalizedString("notifications_info_phone", comment: ""),
                    icon: phoneImage
                ) {
                    PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
                }
                contentStackView.addArrangedSubview(phoneView)
            }
        }

        if let insurance = input.insurance {
            let insuranceNumber = Field(
                title: NSLocalizedString("notifications_info_insurance_number", comment: ""),
                subtitle: insurance.contractNumber
            )
            let incidentNumber = Field(
                title: NSLocalizedString("notifications_info_incident_number", comment: ""),
                subtitle: notification.eventNumber
            )
            let fieldsViews: [UIView] = [ insuranceNumber, incidentNumber ].map {
                let view = NotificationInfoFieldView.fromNib()
                view.set(title: $0.title, subtitle: $0.subtitle)
                return view
            }
            fieldsViews.forEach(contentStackView.addArrangedSubview)
        }
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }
    
    private func setupContentStackView() {
        scrollView.addSubview(contentStackView)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 18
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: contentStackView, in: scrollView) +
            [ contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )
    }
    
    private func setupActionButtonStackView() {
         view.addSubview(actionButtonsStackView)
         
         actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
         actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
         actionButtonsStackView.alignment = .fill
         actionButtonsStackView.distribution = .fill
         actionButtonsStackView.axis = .vertical
         actionButtonsStackView.spacing = 0
         actionButtonsStackView.backgroundColor = .clear
         
         actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
