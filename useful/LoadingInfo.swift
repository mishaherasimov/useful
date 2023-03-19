//
//  LoadingInfo.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

struct LoadInfo: Equatable {
    let state: LoadingState
    let type: LoadingType

    init(_ state: LoadingState, _ type: LoadingType) {
        self.state = state
        self.type = type
    }
}

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
