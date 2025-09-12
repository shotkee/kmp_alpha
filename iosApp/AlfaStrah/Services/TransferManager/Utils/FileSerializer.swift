//
//  FileSerializer.swift
//  AlfaStrah
//
//  Created by vit on 23.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

protocol FileSerializer {
    func serializeToFile(file: TransferredAttachment, parameters: [String: String]) -> Result<URL, AttachmentTransferError>
}
