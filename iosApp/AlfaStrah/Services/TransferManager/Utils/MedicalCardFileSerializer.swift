//
//  MedicalCardFileSerializer.swift
//  AlfaStrah
//
//  Created by vit on 24.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class MedicalCardFileSerializer {
    func serializeToFile(file: TransferredAttachment, payload: [String: Any]) -> Result<URL, AttachmentTransferError> {
        let fileManager = FileManager.default
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        guard let temporaryFileUrl = URL(string: "\(file.dataFileUrl.deletingPathExtension())_medcard_\(timestamp).json")
        else { return .failure(.cantCreateTemporaryFile) }

        fileManager.createFile(atPath: temporaryFileUrl.path, contents: nil)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try? data.write(to: temporaryFileUrl)

            return .success(temporaryFileUrl)
        } catch {
            try? fileManager.removeItem(at: temporaryFileUrl)
            
            return .failure(.cantCreateTemporaryFile)
        }
    }
}
