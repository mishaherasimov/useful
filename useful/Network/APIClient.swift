//
//  APIClient.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

typealias DataResponse = (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?)

final class APIClient {

    static var baseUrl: URL = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "useful-4ad23.firebaseio.com"

        guard let url = components.url else {
            fatalError("invalid API configuration")
        }

        return url
    }()

    var sessionManager: NetworkSessionManager!

    class func isSuccess(httpStatusCode: Int) -> Bool {
        switch httpStatusCode {
        case 200 ... 299:
            return true
        default:
            return false
        }
    }

    init(sessionManager: NetworkSessionManager = NetworkSessionManager()) {
        self.sessionManager = sessionManager
    }

    func handleResponse<P: APIParser>(_ parser: P, response: DataResponse, completionHandler: (APIResponse<P.DecodableType>) -> Void) {
        let result: APIResponse<P.DecodableType>
        
        if let error = response.error {
            result = .failure(.unknown(error))
        } else if let httpStatusCode = response.response?.statusCode {
            result = APIClient.isSuccess(httpStatusCode: httpStatusCode) ? parser.parseResponse(response.data ?? Data()) : .failure(.requestError(statusCode: httpStatusCode))
        } else {
            result = .failure(.unknown(nil))
        }
        
        completionHandler(result)
    }
}
