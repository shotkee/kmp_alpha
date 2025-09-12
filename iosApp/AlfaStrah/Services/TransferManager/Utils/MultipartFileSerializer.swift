//
//  MultipartFileSerializer.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class MultipartFileSerializer: FileSerializer {
    private let boundary: String

    let contentType: String

    init() {
        boundary = "slice.multipart.\(UUID().uuidString)"
        contentType = "multipart/form-data; boundary=\(boundary)"
    }

    func serializeToFile(file: TransferredAttachment, parameters: [String: String]) -> Result<URL, AttachmentTransferError> {
        guard file.contentType.replacingOccurrences(of: "[\\w\\d\\/\\-; \\=]", with: "", options: [ .regularExpression ]).isEmpty else {
            return .failure(.badContentType)
        }

        let enquote: (String) -> String  = { value in
            value
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\r", with: " ")
        }

        let prefixString =
            "--\(boundary)\r\n" +
            "Content-Disposition: form-data; name=\"\(enquote(file.parameterName))\"; filename=\"\(enquote(file.filename))\"\r\n" +
            "Content-Type: \(file.contentType)\r\n\r\n"
        let suffixString =
            "\r\n"
        let endingString =
            "--\(boundary)--\r\n"

        guard
            let prefix = prefixString.data(using: .ascii),
            let suffix = suffixString.data(using: .ascii),
            let ending = endingString.data(using: .ascii),
            let dataFromFile = try? NSData(contentsOf: file.dataFileUrl, options: [ .alwaysMapped ]) as Data
        else { return .failure(.noBody) }

        let fileManager = FileManager.default
        var temporaryFileUrl = file.dataFileUrl.appendingPathExtension("multipartData")
        var index: Int = 2
        while fileManager.fileExists(atPath: temporaryFileUrl.path) {
            temporaryFileUrl = file.dataFileUrl.appendingPathExtension("\(index).multipartData")
            index += 1
            if index > 100 {
                return .failure(.cantCreateTemporaryFile)
            }
        }
        fileManager.createFile(atPath: temporaryFileUrl.path, contents: nil)

        guard let fileHandle = try? FileHandle(forWritingTo: temporaryFileUrl) else {
            return .failure(.cantCreateTemporaryFile)
        }

        fileHandle.seek(toFileOffset: 0)
        for (key, value) in parameters {
            let parameterString =
                "--\(boundary)\r\n" +
                "Content-Disposition: form-data; name=\"\(key)\"\r\n" +
                "\r\n" +
                value + "\r\n"
            if let parameter = parameterString.data(using: .utf8) {
                fileHandle.write(parameter)
            } else {
                fileHandle.closeFile()
                try? fileManager.removeItem(at: temporaryFileUrl)
                return .failure(.cantCreateTemporaryFile)
            }
        }

        fileHandle.write(prefix)
        fileHandle.write(dataFromFile)
        fileHandle.write(suffix)

        fileHandle.write(ending)

        fileHandle.truncateFile(atOffset: fileHandle.offsetInFile)
        fileHandle.closeFile()

        return .success(temporaryFileUrl)
    }
}
