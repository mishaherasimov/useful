//
//  LoadingState.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

enum LoadingState {

    case willLoad
    case isLoading
    case failLoading(title: String, message: String)
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

extension LoadingState: Equatable {

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.willLoad, .willLoad),
             (.isLoading, .isLoading),
             (.failLoading, .failLoading),
             (.didLoad, .didLoad):
            return true
        default:
            return false
        }
    }
}
