//
//  Displayable.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

/// Protocol for getting a displayable representation of object.
protocol Displayable {
    var displayValue: String? { get }
    var debugDisplayValue: String { get }
    var debugInnerError: Error? { get }
}

extension Displayable {
    var displayValue: String? {
        nil
    }

    var debugDisplayValue: String {
        var value = String(describing: self)
        if let innerError = debugInnerError as? Displayable {
            value += "\n\(innerError.debugDisplayValue)"
        }
        return value
    }

    var debugInnerError: Error? {
        nil
    }
}
