//
//  Hash.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    /// Calculates digest with given function.
    func digest(
        length: Int,
        function: (_ message: UnsafeRawPointer, _ length: CC_LONG, _ digest: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>?
    ) -> Data {
        var digestData = Data(count: length)
        digestData.withUnsafeMutableBytes { (digestBytes: UnsafeMutableRawBufferPointer) -> Void in
            guard let digestBase = digestBytes.baseAddress else { return }

            withUnsafeBytes { (messageBytes: UnsafeRawBufferPointer) -> Void in
                guard let messageBase = messageBytes.baseAddress else { return }

                _ = function(messageBase, CC_LONG(count), digestBase.assumingMemoryBound(to: UInt8.self))
            }
        }
        return digestData
    }

    /// Calculates MD5 hash.
    var md5: Data {
        digest(length: Int(CC_MD5_DIGEST_LENGTH), function: CC_MD5)
    }

    /// Calculates SHA1 hash.
    var sha1: Data {
        digest(length: Int(CC_SHA1_DIGEST_LENGTH), function: CC_SHA1)
    }
}

extension String {
    /// Calculates MD5 hash.
    var md5: Data {
        guard let data = data(using: .utf8) else { fatalError("Cannot get data from string.") }
        return data.md5
    }

    /// Calculates SHA1 hash.
    var sha1: Data {
        guard let data = data(using: .utf8) else { fatalError("Cannot get data from string.") }
        return data.sha1
    }
}
