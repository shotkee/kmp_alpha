//
//  FormDataOperations.swift
//  AlfaStrah
//
//  Created by vit on 20.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	struct FormDataOperations {
		// MARK: - Form data manipulation
		static func deleteFormDataFromCurrentScreenEntry(_ formDataEntry: FormDataEntryComponentDTO?) {
			if let postData = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData,
			   let formDataIndex = postData.firstIndex(where: { $0 === formDataEntry }) {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData?.remove(at: formDataIndex)
			}
			
			Self.printPostData()
		}
		
		static func addFormDataToCurrentScreenEntry(_ formDataEntry: FormDataEntryComponentDTO?) {
			guard let formDataEntry
			else { return }
			
			if let postData = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData,
			   let formDataIndex = postData.firstIndex(where: { $0 === formDataEntry }) {
				return	// entry already selected to send
			}
			
			if ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData == nil {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData = [formDataEntry]
			} else {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData?.append(formDataEntry)
			}
			
			Self.printPostData()
		}
		
		static func replaceFormDataOnCurrentScreenEntry(_ formDataEntry: FormDataEntryComponentDTO) {
			if let postData = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData,
			   let formDataIndex = postData.firstIndex(where: { $0.name == formDataEntry.name }) {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData?[formDataIndex] = formDataEntry
			}
			
			Self.printPostData()
		}
		
		static func replaceFormData(for events: EventsDTO?, with data: Any?, action: ((EventsDTO) -> Void)?) {
			guard let formDataEntryName = events?.formDataPatchKey
			else { return }
			
			let body: [String: Any?] = [
				FormDataEntryComponentDTO.Key.name.rawValue: formDataEntryName,
				FormDataEntryComponentDTO.Key.value.rawValue: data
			]
			
			let entry = FormDataEntryComponentDTO(body: body)
			Self.replaceFormDataOnCurrentScreenEntry(entry)
			
			if let onChange = events?.onChange {
				let onChangeCallContainer = EventsDTO(onTap: onChange, onRender: nil, onChange: nil)
				
				action?(onChangeCallContainer)
			}
		}
		
		static func printPostData() {
			guard let topScreenEntry = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry,
				  let topScreenEntryPostData = topScreenEntry.postData
			else { return }
			
			print("post data: \(topScreenEntry.screenId)")
			
			for postEntry in topScreenEntryPostData {
				print("   post data: name = \(postEntry.name) value = \(postEntry.value)")
			}
		}
	}
}
