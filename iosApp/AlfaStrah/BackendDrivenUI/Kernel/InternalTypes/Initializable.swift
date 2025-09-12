//
//  Initializable.swift
//  AlfaStrah
//
//  Created by vit on 19.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	protocol ComponentInitializable {
		init(body: [String: Any])
		associatedtype Key: RawRepresentable where Key.RawValue: StringProtocol
	}
	
}

extension BDUI {
	typealias Widget = UIView & WidgetInitializable
	typealias Header = UIView & HeaderInitializable
	typealias Footer = UIView & FooterInitializable
	typealias Action = NSObject & ActionInitializable
	
	// MARK: - For future use https://github.com/swiftlang/swift/issues/66740
//	protocol Initializable {
//	   associatedtype T
//		
//		init(
//			block: T,
//			horizontalInset: CGFloat,
//			action: @escaping (EventsDTO) -> Void
//		)
//	}
		
	protocol WidgetInitializable {
		associatedtype W: WidgetDTO
		
		init(
			block: W,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		)
	}
	
	protocol HeaderInitializable {
		associatedtype H: HeaderDTO
		
		init(
			block: H,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		)
	}
	
	protocol FooterInitializable {
		associatedtype F: FooterDTO
		
		init(
			block: F,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		)
	}
	
	protocol ActionInitializable {
		associatedtype A: ActionDTO
		
		init(
			block: A
		)
	}
}
