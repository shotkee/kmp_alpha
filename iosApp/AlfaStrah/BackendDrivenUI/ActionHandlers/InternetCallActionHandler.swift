//
//  InternetCallActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InternetCallActionHandler: ActionHandler<InternetCallActionDTO>,
									 AlertPresenterDependency,
									 VoipServiceDependency {
		var alertPresenter: AlertPresenter!
		var voipService: VoipService!
		
		private var voipServiceAvailability: VoipServiceAvailability?
		private let sosStoryboard: UIStoryboard = UIStoryboard(name: "Sos", bundle: nil)
		
		required init(
			block: InternetCallActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let voipCall = block.voipCall
				else {
					syncCompletion()
					return
				}
				
				self.showVoipCall(with: voipCall, from: from)
				
				syncCompletion()
			}
		}
		
		private func showVoipCall(with voipCall: VoipCall, from: ViewController) {
			if let voipServiceAvailability {
				if self.voipServiceAvailability != .disconnected {
					ErrorHelper.show(error: nil, alertPresenter: self.alertPresenter)
					return
				}
			} else {
				self.voipServiceAvailability = .disconnected
				
				voipService.subscribeForAvailability { voipServiceAvailability in
					self.voipServiceAvailability = voipServiceAvailability
				}.disposed(by: disposeBag)
			}
			
			let viewController: VoipCallViewController = sosStoryboard.instantiate()
			ApplicationFlow.shared.container.resolve(viewController)
			
			viewController.output = .init(
				close: {
					self.flow?.initialViewController.popViewController(animated: true)
				},
				sendPhoneNumberDigit: { digit in
					self.voipService.send(digit: digit)
				},
				endCall: { [weak viewController] in
					self.voipService.endCall()
					viewController?.notify.updateState(.disconnected)
				},
				muteCall: { mute in
					self.voipService.muteCall(mute)
				},
				startCall: {
					self.voipService.call(voipCall)
				}
			)
			
			voipService.subscribeForAvailability { [weak viewController] voipServiceAvailability in
				guard let viewController
				else { return }
				
				switch voipServiceAvailability {
					case .connected:
						viewController.notify.updateState(.connected)
					case .disconnected, .pendingDisconnect:
						viewController.notify.updateState(.disconnected)
					case .speaking:
						viewController.notify.updateState(.speaking)
				}
			}.disposed(by: viewController.disposeBag)
			
			viewController.hidesBottomBarWhenPushed = true
			
			from.navigationController?.pushViewController(viewController, animated: true)
		}
	}
}
