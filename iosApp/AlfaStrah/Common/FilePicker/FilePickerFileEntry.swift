//
//  FilePickerFileEntry.swift
//  AlfaStrah
//
//  Created by vit on 01.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class FilePickerFileEntry: StateObservable {
	private (set) var attachment: Attachment?
	
	var state: FilePickerEntryState {
		didSet {
			switch state {
				case .ready(_, let attachment):
					self.attachment = attachment
					
				case 
					.error(_, let attachment, _),
					.processing(_, let attachment, _):
					self.attachment = attachment
					
			}
			stateChanged?(state)
		}
	}
	
	var stateChanged: ((FilePickerEntryState) -> Void)?
	
	func setStateObserver(_ listener: @escaping (FilePickerEntryState) -> Void) {
		stateChanged = listener
	}
	
	func deleteStateObserver() {
		stateChanged = nil
	}
	
	init(
		state: FilePickerEntryState
	) {
		self.state = state
		
		switch state {
			case .ready(_, let attachment):
				self.attachment = attachment
				
			case
				.error(_, let attachment, _),
				.processing(_, let attachment, _):
				self.attachment = attachment
				
		}
	}
	
	func updateWithErrorState() {
		let attachment = self.attachment
		
		self.state = .error(previewUrl: attachment?.url, attachment: attachment)
	}
}

enum FilePickerEntryState: Equatable {
	enum ProcessingType {
		case downloading
		case compressing
		case uploading
	}
	
	enum ErrorType {
		case downloading
		case common
	}
	
	case ready(previewUrl: URL?, attachment: Attachment?)
	case processing(previewUrl: URL?, attachment: Attachment?, type: ProcessingType? = nil)
	case error(previewUrl: URL?, attachment: Attachment?, type: ErrorType? = nil)
	
	static func == (lhs: FilePickerEntryState, rhs: FilePickerEntryState) -> Bool {
		switch (lhs, rhs) {
			case (.ready, .ready):
				return true
			case (.processing, .processing):
				return true
			case (.error, .error):
				return true
			default:
				return false
		}
	}
	
	var isError: Bool {
		if case .error = self { return true }
		else { return false }
	}
}
