//
//  URL+QueryItem.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 20.09.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

extension URL {
    @discardableResult func appendingQueryItem(itemName: String, itemValue: String) -> URL
    {
        guard var components = URLComponents(
            url: self,
            resolvingAgainstBaseURL: true
        ) else { return self }
                
        let item = URLQueryItem(
            name: itemName,
            value: itemValue
        )
        var queryItems = components.queryItems ?? []
        queryItems.append(item)
        
        components.queryItems = queryItems
        
        return components.url ?? self
    }

    @discardableResult func appendingQuery(items: [String: String]) -> URL
    {
        var url = self
        
        for (key, item) in items {
           url = url.appendingQueryItem(itemName: key, itemValue: item)
        }
        
        return url
    }
}
