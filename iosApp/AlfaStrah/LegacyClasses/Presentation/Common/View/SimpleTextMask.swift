//
//  SimpleTextMask.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 25/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import Foundation

class SimpleTextMask: NSObject {
    // mask format: <this will not be changed>[<this characters will be changed>]
    // ex: format: abc[000] inputString: a output: abca
    // ex: format: +7 [000] [000]-[00]-[00] inputString: a output: +7 a
    // ex: format: +7 [000] [000]-[00]-[00] inputString: 9112333 output: +7 911 233-3
    var maskFormat = ""

    var changeableCharacterRanges: [NSRange] {
        let mask = maskFormat as NSString
        guard mask.length > 0 else { return [] }

        var retVal: [NSRange] = []
        var canChange = false
        var skippedChars = 0
        for maskIndex in 0 ..< mask.length {
            let maskChar = mask.substring(with: NSRange(location: maskIndex, length: 1))
            if maskChar == "[" {
                canChange = true
                skippedChars += 1
                continue
            } else if maskChar == "]" {
                canChange = false
                skippedChars += 1
                continue
            }
            if canChange {
                retVal.append(NSRange(location: maskIndex - skippedChars, length: 1))
            }
        }
        return retVal
    }

    func removeMaskRangeMarkers(string: String) -> String {
        let input = string as NSString
        var retStr = ""
        for index in 0 ..< input.length {
            let str = input.substring(with: NSRange(location: index, length: 1))
            if str == "[" {
                continue
            } else if str == "]" {
                continue
            }
            retStr += str
        }
        return retStr
    }

    init(format: String) {
        maskFormat = format
    }

    func mask(string: String) -> String {
        let mask = removeMaskRangeMarkers(string: maskFormat) as NSString
        guard mask.length > 0 else {
            // no mask to apply
            return string
        }

        let input = string as NSString
        guard input.length > 0 else {
            // nothing to mask
            return string
        }

        var resString = mask
        let rangesOfChangeableChars = changeableCharacterRanges
        guard !rangesOfChangeableChars.isEmpty else {
            // nothing to change
            return string
        }

        var shouldTrim = true
        var changedChars = 0
        var lastIndex = 0

        for index in 0 ..< input.length {
            guard index < mask.length else {
                shouldTrim = false
                break
            }

            let targetRange = NSRange(location: index, length: 1)
            let str = input.substring(with: targetRange)

            let containsTest = { (range: NSRange) -> Bool in
                NSEqualRanges(targetRange, range)
            }

            let contains = rangesOfChangeableChars.contains(where: containsTest)

            if str == mask.substring(with: targetRange) {
                // already conforms to mask
                lastIndex = index
                if contains {
                    changedChars += 1
                }
                if changedChars >= rangesOfChangeableChars.count {
                    shouldTrim = false
                    break
                }
                continue
            }

            if contains {
                let idx = changedChars
                resString = resString.replacingCharacters(in: rangesOfChangeableChars[idx], with: str) as NSString
                changedChars += 1
                if changedChars >= rangesOfChangeableChars.count {
                    shouldTrim = false
                    break
                }
                shouldTrim = true
                lastIndex = index
            } else {
                let idx = changedChars
                resString = resString.replacingCharacters(in: rangesOfChangeableChars[idx], with: str) as NSString
                shouldTrim = true
                lastIndex = rangesOfChangeableChars[idx].location
                changedChars += 1
                if changedChars >= rangesOfChangeableChars.count {
                    shouldTrim = false
                    break
                }
            }
        }

        if shouldTrim {
            let loc = lastIndex + 1
            let len = mask.length - loc
            let trimRange = NSRange(location: loc, length: len)
            resString = resString.replacingCharacters(in: trimRange, with: "") as NSString
        }

        let retVal = removeMaskRangeMarkers(string: resString as String)
        return retVal
    }
}
