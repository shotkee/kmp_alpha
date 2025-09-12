//
//  ClinicAppointmentStatusViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

final class ClinicAppointmentStatusViewController: ViewController,
												   RMRNavBarViewControllerDelegate {
    struct Input {
        var kind: Kind
        var data: () -> NetworkData<Bool>
    }

    struct Output {
        var refresh: () -> Void
        var doneTap: () -> Void
    }

    struct Notify {
        var changed: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let self,
				  self.isViewLoaded
			else { return }

            self.update()
        }
    )

    var showNavigationBar: Bool {
        false
    }

    enum Kind: Equatable {
        case offlineAppointment
        case onlineAppointmentCreate
        case commonAppointmentCancel(message: String)
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var doneButton: RoundEdgeButton!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var tryAgainButton: RoundEdgeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
        output.refresh()
    }

    // MARK: - Setup UI

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
		doneButton.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
		doneButton <~ Style.RoundedButton.redBackground
		
        titleLabel <~ Style.Label.primaryHeadline1
        errorLabel <~ Style.Label.secondaryText
        subtitleLabel <~ Style.Label.secondaryText
        tryAgainButton <~ Style.RoundedButton.redBordered
        tryAgainButton.setTitle(NSLocalizedString("common_retry", comment: ""), for: .normal)
    }

    private func update() {
        switch input.data() {
            case .loading:
                iconImageView.image = UIImage(named: "file")
                subtitleLabel.text = nil
                doneButton.isHidden = true
                tryAgainButton.isHidden = true
                errorLabel.text = nil
                switch input.kind {
                    case .offlineAppointment:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_creation", comment: "")
                    case .onlineAppointmentCreate:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_creation", comment: "")
                    case .commonAppointmentCancel:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_cancelation", comment: "")
                }
            case .data(let success):
                iconImageView.image = UIImage(named: "icon-check-success")
                doneButton.isHidden = false
                tryAgainButton.isHidden = true
                errorLabel.text = nil
                switch input.kind {
                    case .offlineAppointment:
                        titleLabel.text = NSLocalizedString("clinic_appointment_success_offline_title", comment: "")
                        subtitleLabel.text = NSLocalizedString("clinic_appointment_success_offline_subtitle", comment: "")
                    case .onlineAppointmentCreate:
                        titleLabel.text = NSLocalizedString("clinic_appointment_success_online_title", comment: "")
                        subtitleLabel.text = NSLocalizedString("clinic_appointment_success_online_subtitle", comment: "")
                    case .commonAppointmentCancel(let message):
                        if success {
                            titleLabel.text = NSLocalizedString("clinic_appointment_cancel_online_title", comment: "")
                            subtitleLabel.text = message
                        } else {
                            iconImageView.image = UIImage(named: "icon-check-failure")
                            titleLabel.text = NSLocalizedString("clinic_appointment_status_cancelation_prohibited", comment: "")
                            subtitleLabel.text = NSLocalizedString("common_please_try_again", comment: "")
                        }
                }
            case .error(let error):
                iconImageView.image = UIImage(named: "icon-check-failure")
                doneButton.isHidden = false
                tryAgainButton.isHidden = false
                errorLabel.text = (error as? Displayable)?.displayValue
                subtitleLabel.text = NSLocalizedString("common_please_try_again", comment: "")
                switch input.kind {
                    case .offlineAppointment:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_creation_error", comment: "")
                    case .onlineAppointmentCreate:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_creation_error", comment: "")
                    case .commonAppointmentCancel:
                        titleLabel.text = NSLocalizedString("clinic_appointment_status_appointment_cancelation_error", comment: "")
                }
        }

        errorLabel.isHidden = errorLabel.text == nil
        subtitleLabel.isHidden = subtitleLabel.text == nil
    }

    @IBAction func tryAgainTap(_ sender: UIButton) {
        output.refresh()
    }

    @IBAction func doneTap(_ sender: UIButton) {
        output.doneTap()
    }
}
