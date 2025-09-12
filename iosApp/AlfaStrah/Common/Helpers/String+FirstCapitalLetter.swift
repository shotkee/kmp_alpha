//
//  String+FirstCapitalLetter.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
	
	func firstLetter() -> String {
		guard let firstChar = self.first else 
		{
			return ""
		}
		
		return String(firstChar)
	}
}
