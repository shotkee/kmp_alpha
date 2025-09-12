//
//  StringUtils.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 24.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

func getString(from byteArray: [UInt8]) -> String {
    guard let string = String(bytes: byteArray, encoding: .ascii) else {
        fatalError("Malformed array")
    }
    return string
}

func getSeedAndHash(
    _ parameters: String...,
    secretKey: String,
    deviceToken: MobileDeviceToken
) -> (seed: String, hash: String) {
    let seed = UUID().uuidString
    let hash = "\(parameters.joined())\(deviceToken)\(seed)\(secretKey)".sha1.hexadecimal
    return (seed: seed, hash: hash)
}

func bytesCountFormatted(from bytesCount: Int64) -> String {
	let formatter = ByteCountFormatter()
	formatter.allowedUnits = [.useMB, .useKB]
	formatter.countStyle = .file
	return formatter.string(fromByteCount: bytesCount)
}
