//
//  VoipCallViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import AVFoundation

class VoipCallViewController: ViewController, UITextFieldDelegate {
    struct Notify {
        let updateState: (_ state: State) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify: Notify = Notify(
        updateState: { [weak self] state in
            guard let self,
                  self.isViewLoaded
            else { return }
            
            self.update(with: state)
        }
    )
    
    enum State {
        case connected
        case speaking
        case disconnected
    }
    
    struct Output {
        let close: () -> Void
        let sendPhoneNumberDigit: (String) -> Void
        let endCall: () -> Void
        let muteCall: (Bool) -> Void
        let startCall: () -> Void
    }

    var output: Output!

    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var inputTextField: NoCursorTextField!
    @IBOutlet private var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var showNumpadButton: UIButton!
    @IBOutlet private var muteMicrophoneButton: UIButton!
	@IBOutlet private var titleLabel: UILabel!
	
	@IBOutlet private var muteLabel: UILabel!
	@IBOutlet private var speakerLabel: UILabel!
	@IBOutlet private var keypadLabel: UILabel!
	
	private let keyboardBehavior = KeyboardBehavior()
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var callWasAnswered: Bool = false
    private var callStartDate: Date = Date()
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextField.text = ""
        stateLabel.text = ""
        inputTextField.delegate = self

        try? audioSession.setCategory(.playAndRecord)
        try? audioSession.setMode(.voiceChat)

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let `self` = self else { return }

            let frameInView = self.view.convert(frame, from: nil)
            let offset = max(self.view.bounds.maxY - frameInView.minY - self.view.safeAreaInsets.bottom, 0)
            self.bottomLayoutConstraint.constant = offset + 20
            self.view.layoutIfNeeded()
        }
        
		// hide for now till aligned with buiseness requirements
        showNumpadButton.isHidden = true
		inputTextField.isHidden = true
		
		// hide for now till aligned with buiseness requirements
        muteMicrophoneButton.isHidden = true
        
        navigationController?.setNavigationBarHidden(true, animated: false)
		
		titleLabel.font = Style.Font.title2
		stateLabel.font = Style.Font.text
		inputTextField.font = Style.Font.title1
		muteLabel.font = Style.Font.subhead
		speakerLabel.font = Style.Font.subhead
		keypadLabel.font = Style.Font.subhead
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		navigationController?.setNavigationBarHidden(true, animated: false)
		
        keyboardBehavior.subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        output.startCall()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(false)
        keyboardBehavior.unsubscribe()

        output.endCall()
        stopCallTimer()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func startCallTimer() {
        let seconds = 0
        let minutes = 0
        stateLabel.text = String(
            format: NSLocalizedString("sos_voip_timer", comment: ""),
            minutes, seconds
        )
        callStartDate = Date()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCallTimer), userInfo: nil, repeats: true)
    }

    private func stopCallTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateCallTimer() {
        let callTime = Int(Date().timeIntervalSince(callStartDate))
        let seconds = callTime % 60
        let minutes = (callTime / 60) % 60
        stateLabel.text = String(
            format: NSLocalizedString("sos_voip_timer", comment: ""),
            minutes, seconds
        )
    }
    
    private var previousState: State?

    private func update(with state: State) {
        guard previousState != state
        else { return }
        
        previousState = state
        
        switch state {
            case .connected:
                stateLabel.text = NSLocalizedString("sos_voip_connected_status", comment: "")
            case .speaking:
                startCallTimer()
                callWasAnswered = true
            case .disconnected:
                stopCallTimer()
                stateLabel.text = NSLocalizedString("sos_voip_disconnected_status", comment: "")
                output.close()
        }
    }

    @IBAction func muteTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        output.muteCall(sender.isSelected)
    }

    @IBAction func enableSpeakerTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            try? audioSession.overrideOutputAudioPort(.speaker)
        } else {
            try? audioSession.overrideOutputAudioPort(.none)
        }
    }

    @IBAction func endCallTap() {
        output.endCall()
    }

    @IBAction func numpadTap() {
        if inputTextField.isFirstResponder {
            inputTextField.resignFirstResponder()
        } else {
            inputTextField.becomeFirstResponder()
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        output.sendPhoneNumberDigit(string)
        return true
    }
}
