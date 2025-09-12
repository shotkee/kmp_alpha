//
//  Array+.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

extension Array {
    func chunks(chunkSize: Int) -> [[Element]] {
        stride(
            from: 0,
            to: self.count,
            by: chunkSize
        ).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Array where Element: Hashable 
{
	func uniqued() -> [Element]
	{
		var seen = Set<Element>()
		
		return filter { seen.insert($0).inserted }
	}
}
