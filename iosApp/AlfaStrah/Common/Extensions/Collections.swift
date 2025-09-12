//
//  Collections.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 18/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        indices.contains(index) ? self[index] : nil
    }
}
