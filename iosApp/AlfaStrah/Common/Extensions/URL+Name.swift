//
//  URL+Name.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import MobileCoreServices

extension URL {
    // "somePDF.pdf"
    var filename: String {
        self.lastPathComponent
    }

    // somePDF.pdf -> somePDF
    var fileNameWithoutExtension: String {
        self.deletingPathExtension().lastPathComponent
    }

    // "pdf"
    var fileExtension: String {
        self.pathExtension
    }
	
	var uti: String? {
		if let uti = UTTypeCreatePreferredIdentifierForTag(
			kUTTagClassFilenameExtension,
			self.pathExtension as NSString,
			nil
		)?.takeRetainedValue() {
			if UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() != nil {
				return uti as String
			}
		}
		
		return nil
	}
}
