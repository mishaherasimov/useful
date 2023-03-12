//
//  LoadingInfo.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

typealias LoadInfo = (state: LoadingState, type: LoadingType)

enum LoadingType {

    case fullReload
    case loadNew
}

enum LoadingState: Equatable {

    case willLoad
    case isLoading
    case failLoading
    case didLoad

    var isActive: Bool {

        switch self {
        case .isLoading, .willLoad:
            return true
        case .failLoading, .didLoad:
            return false
        }
    }
}
