//
// ShimmerDirection
// AlfaStrah
//
// Created by Vasiliy Kotsiuba on 13 December 2017.
// Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Represents a `CAGradientLayer`'s `startPoint` or `endPoint`, respectively.
enum GradientProperty {
    case startPoint
    case endPoint
}

/// The direction to slide in.
enum ShimmerDirection {
    case right
    case left

    /// Creates transition values for the corresponding `GradientProperty`.
    func transition(for point: GradientProperty) -> (from: CGPoint, to: CGPoint) {
        switch (self, point) {
            case (.right, .startPoint):
                return (from: CGPoint(x: -1, y: 0), to: CGPoint(x: 1, y: 0))
            case (.right, .endPoint):
                return (from: CGPoint(x: 0, y: 0), to: CGPoint(x: 2, y: 0))
            case (.left, .startPoint):
                return (from: CGPoint(x: 1, y: 0), to: CGPoint(x: -1, y: 0))
            case (.left, .endPoint):
                return (from: CGPoint(x: 2, y: 0), to: CGPoint(x: 0, y: 0))
        }
    }
}
