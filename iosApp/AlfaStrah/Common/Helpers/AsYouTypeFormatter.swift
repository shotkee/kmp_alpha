//
//  AsYouTypeFormatter.swift
//  StringMasker
//
//  Created by Stanislav Starzhevskiy on 06.09.17.
//  Copyright © 2017 _My_Company_. All rights reserved.
//

import Foundation

enum CaretPosition {
    case end
    case position(Int)
}

struct FormatResult {
    var string: String
    var caretPosition: CaretPosition
}

enum InputAction {
    case append(string: String, target: String)
    case deleteLast(target: String)
    case deletion(target: String, range: Range<String.Index>)
    case insertion(string: String, target: String, range: Range<String.Index>)

    var result: String {
        switch self {
            case .append(let string, let target):
                return target.appending(string)
            case .deleteLast(let target):
                return String(target.dropLast())
            case .deletion(let target, let range):
                return target.replacingCharacters(in: range, with: "")
            case .insertion(let string, let target, let range):
                return target.replacingCharacters(in: range, with: string)
        }
    }
}

protocol AsYouTypeFormatter {
    func format(existing: String, input: String, range: NSRange) -> FormatResult
    func format(_ input: InputAction) -> FormatResult
    func unformatted(_ string: String) -> String
}

extension AsYouTypeFormatter {
    func format(existing: String, input: String, range: NSRange) -> FormatResult {
        let action = inputAction(from: input, targetRange: range, target: existing)
        return format(action)
    }

    func inputAction(from input: String, targetRange range: NSRange, target: String) -> InputAction {
        guard let stringIndexRange = Range(range, in: target) else { return .append(string: "", target: target) }

        let lowerBound = stringIndexRange.lowerBound
        if !input.isEmpty && lowerBound == target.endIndex {
            return .append(string: input, target: target)
        } else if input.isEmpty && !target.isEmpty && lowerBound == target.index(before: target.endIndex) {
            return .deleteLast(target: target)
        } else if !input.isEmpty {
            return .insertion(string: input, target: target, range: stringIndexRange)
        } else {
            return .deletion(target: target, range: stringIndexRange)
        }
    }
}

struct PhoneNumberFormatter: AsYouTypeFormatter {
    /// area code to substitute
    var predefinedAreaCode: Int?
    /// number of digits without country code
    var maxNumberLength: Int? = 15

    func format(_ input: InputAction) -> FormatResult {
        switch input {
            case .append:
                return FormatResult(string: format(input.result), caretPosition: .end)
            case .deleteLast:
                return FormatResult(string: input.result, caretPosition: .end)
            case .deletion(let target, let range):
                let pos = target.distance(from: target.startIndex, to: range.lowerBound)
                let formatted = format(input.result)
                var resPos = CaretPosition.end
                if formatted.count > pos {
                    resPos = .position(pos)
                }
                return FormatResult(string: formatted, caretPosition: resPos)
            case .insertion(let string, let target, let range):
                let resStr = input.result
                let prefix = target.prefix(upTo: range.lowerBound)
                let suffix = resStr.suffix(string.count)
                let formattedPrefix = format(prefix + string)
                let resPos = CaretPosition.position(formattedPrefix.count)
                let formatted = format(formattedPrefix + suffix)
                return FormatResult(string: formatted, caretPosition: resPos)
        }
    }

    private func format(_ string: String) -> String {
        if string.isEmpty {
            return string
        }

        var plain = unformatted(string)
        if let maxNumbLength = maxNumberLength, plain.count > maxNumbLength {
            plain = String(plain.prefix(maxNumbLength))
        }

        let acPattern: String
        var replacePattern = self.replacePattern

        if let code = predefinedAreaCode {
            acPattern = areaCodePattern(for: code)
            if (code == 1 || code == 7) && plain.count < 3 {
                replacePattern = replacePatternShort
            }
        } else if plain.count < 2 {
            guard let code = Int(plain) else { return "" }

            acPattern = areaCodePattern(for: code)
            replacePattern = replacePatternShort
        } else {
            guard let tryFirst = Int(plain.prefix(1)), let tryFirstTwo = Int(plain.prefix(2)) else { return "" }

            if tryFirst == 1 || tryFirst == 7 {
                acPattern = areaCodePattern(for: tryFirst)
                if plain.count < 4 {
                    replacePattern = replacePatternShort
                }
            } else {
                acPattern = areaCodePattern(for: tryFirstTwo)
            }
        }

        let fullPattern = acPattern + formatPattern
        let formatted = plain.replacingOccurrences(of: fullPattern, with: replacePattern, options: .regularExpression)
        let clean = formatted.replacingOccurrences(of: cleanPattern, with: "", options: .regularExpression)
        return clean
    }

    func unformatted(_ string: String) -> String {
        string.replacingOccurrences(of: toPlainPattern, with: "", options: .regularExpression)
    }

    private var formatPattern: String {
        var prefix = "((?<=.)"
        if predefinedAreaCode != nil {
            prefix = "^("
        }
        let firstPart = prefix + "[0-9]{1,3})?((?<=.{3})[0-9]{1,3})?"
        let secondPart = "((?<=.{2})[0-9]{1,2})?((?<=.{2})[0-9]{1,2})?((?<=.{2})[0-9]{1,4})?"
        return firstPart + secondPart
    }

    var toPlainPattern: String {
        if let code = predefinedAreaCode {
            return "^\\+\(code)|\\D"
        }
        return "\\D"
    }

    private var replacePattern: String {
        if let areaCode = predefinedAreaCode {
            return "+\(areaCode) ($1) $2-$3-$4-$5"
        } else {
            return "+$1 ($2) $3-$4-$5-$6"
        }
    }

    private var replacePatternShort: String {
        if let areaCode = predefinedAreaCode {
            return "+\(areaCode) $1 $2-$3-$4-$5"
        } else {
            return "+$1 $2 $3-$4-$5-$6"
        }
    }

    private var cleanPattern: String {
        "--|-$|\\(\\)| -| \\(\\)"
    }

    private func areaCodePattern(for areaCode: Int) -> String {
        if predefinedAreaCode != nil {
            return ""
        }
        switch areaCode {
            case 1, 7:
                return "^\\+?([0-9]{1})"
            default:
                if lessThenThreeDigitsAreaCodes.contains(areaCode) {
                    return "^\\+?([0-9]{2})"
                } else {
                    return "^\\+?([0-9]{1,3})"
                }
        }
    }

    /// World phone region codes. Data taken from Wikipedia.
    /// This is the code you enter after + or 00 to call countries(regions) around the world.
    /// For example: you enter +1 to call United States or +7 to call Russia or Kazahstan or +39 to call Italy.
    /// This is an array of region codes that consist of one or two digits.
    /// All other known codes are 3 digit codes.
    private let lessThenThreeDigitsAreaCodes = [
        1,
        20, 27, 28,
        30, 31, 32, 33, 34, 36, 39,
        40, 41, 43, 44, 45, 46, 47, 48, 49,
        51, 52, 53, 54, 55, 56, 57, 58,
        61, 62, 63, 64, 65, 66,
        7,
        81, 82, 83, 84, 86, 89,
        90, 91, 92, 93, 94, 95, 98
    ]
}
