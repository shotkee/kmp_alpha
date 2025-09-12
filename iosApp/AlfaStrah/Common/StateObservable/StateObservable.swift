//
//  StateObservable.swift
//  AlfaStrah
//
//  Created by vit on 01.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

protocol StateObservable {
	associatedtype State
	
	var stateChanged: ((State) -> Void)? { get }
	
	func setStateObserver(_ listener: @escaping (State) -> Void)
	func deleteStateObserver()
}
