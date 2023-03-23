//
//  ApiError.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

public enum APIError {

    case decodingError(Error?)
    case unknown(Error?)
    case requestError(statusCode: Int)
}

extension APIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requestError(let statusCode):
            return "Request error with statusCode: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(String(describing: error))"
        case .unknown:
            return "Unable to connect. Please try again later."
        }
    }
}
