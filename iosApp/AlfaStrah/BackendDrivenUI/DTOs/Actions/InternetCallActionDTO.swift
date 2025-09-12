//
//  InternetCallActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InternetCallActionDTO: ActionDTO {
		enum Key: String {
			case internetCall = "internetCall"
		}
		
		let voipCall: VoipCall?
		
		required init(body: [String: Any]) {
			if let raw = body[Key.internetCall] as? [String: Any],
			   let voipCall = VoipCallTransformer().transform(source: raw).value {
				self.voipCall = voipCall
			} else {
				self.voipCall = nil
			}
			
			super.init(body: body)
		}
	}
}
