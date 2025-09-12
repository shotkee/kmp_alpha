//
//  FileMultipartSerializer.swift
//  FitBox
//
//  Created by Ilyas Siraev on 26.07.2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import Foundation
import Legacy

struct Multipart {
    var name: String
    var filename: String?
    var contentType: String?
    var transferEncoding: String?
    var data: Data

    init(name: String, string: String) {
        self.name = name
        filename = nil
        contentType = nil
        transferEncoding = nil
        data = string.data(using: .utf8) ?? Data()
    }
    init(name: String, imageData: Data, fileName: String, contentType: String?, transferEncoding: String? = "binary") {
        self.name = name
        self.filename = fileName
        self.contentType = contentType
        self.transferEncoding = transferEncoding
        self.data = imageData
    }
}

class MultipartSerializer: HttpSerializer {
    typealias Value = [Multipart]

    private let boundary = "\(UUID().uuidString)"

    var contentType: String {
        "multipart/form-data; charset=utf-8; boundary=\(boundary)"
    }

    func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .failure(.error(AttachmentTransferError.noBody)) }

        var data = Data()
        for file in value {
            let suffixString = "\r\n"
            var paramArray: [String] = []
            paramArray.append("--\(boundary)")
            var name = "Content-Disposition: form-data; name=\"\(file.name)\""
            if let fileName = file.filename {
                name += "; filename=\"\(fileName)\""
            }
            paramArray.append(name)
            if let binary = file.transferEncoding {
                paramArray.append("Content-Transfer-Encoding: \(binary)")
            }

            if let contentType = file.contentType {
                paramArray.append("Content-Type: \(contentType)")
            }

            paramArray.append("Content-Length: \(file.data.count)")
            let prefixString = paramArray.joined(separator: suffixString) + suffixString + suffixString

            guard
                let prefix = prefixString.data(using: .ascii),
                let suffix = suffixString.data(using: .ascii)
            else {
                return .failure(.error(AttachmentTransferError.noBody))
            }

            data.append(prefix)
            data.append(file.data)
            data.append(suffix)
        }

        let suffixString =
            "\r\n" +
            "\r\n--\(boundary)--\r\n"

        guard let suffix = suffixString.data(using: .ascii) else { return .failure(.error(AttachmentTransferError.noBody)) }

        data.append(suffix)

        return .success(data)
    }

    func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        fatalError("Not implemented")
    }
}
