//
//  ApiResponse.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

public enum APIResponse<Value> {

    case success(Value)
    case failure(APIError)

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    public var error: APIError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
