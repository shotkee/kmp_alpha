//
//  NetworkData.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 01/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

enum NetworkData<T> {
    case loading
    case data(T)
    case error(Error)

    var isLoading: Bool {
        switch self {
            case .loading:
                return true
            default:
                return false
        }
    }
}
