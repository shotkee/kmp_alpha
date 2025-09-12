//
//  CascanaChatOperator.swift
//  AlfaStrah
//
//  Created by vit on 06.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class CascanaChatOperator: Entity, Operator, Hashable {
    private let name: String?
	private let senderId: String?
	private let requestId: String?
	private var rate: Int?
    
    init(
		name: String,
		senderId: String?,
		requestId: String?,
		rate: Int? = nil
	) {
        self.name = name
		self.senderId = senderId
		self.requestId = requestId
		self.rate = rate
    }
    
    func getID() -> String {
        return String(hashValue)
    }
    
    func getName() -> String {
        return name ?? ""
    }
    
    func getAvatarURL() -> URL? {
        nil
    }
    
    func getTitle() -> String? {
        nil
    }
    
    func getInfo() -> String? {
        nil
    }
	
	func getRate() -> Int? {
		return rate
	}
	
	func setRate(_ rate: Int) {
		self.rate = rate
	}
	
	func getSenderId() -> String? {
		return self.senderId
	}
	
	func getRequestId() -> String? {
		return self.requestId
	}
	
	func ratingCanBeGiven() -> Bool {
		guard let senderId,
			  let requestId,
			  senderId != Constants.cascanaInvalidUUIDString,
			  requestId != Constants.cascanaInvalidUUIDString
		else { return false }
		
		return true
	}
	
    static func == (lhs: CascanaChatOperator, rhs: CascanaChatOperator) -> Bool {
		return lhs.name == rhs.name && lhs.senderId == rhs.senderId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
		hasher.combine(senderId)
    }
	
	struct Constants {
		static let cascanaInvalidUUIDString = "00000000-0000-0000-0000-000000000000"
	}
}
