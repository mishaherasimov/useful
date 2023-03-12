//
//  APIRequest.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

protocol URLRequestProvider {
    var urlRequest: URLRequest { get }
}

protocol APIRequest: URLRequestProvider {
    var method: HTTPMethod { get }
    var url: URL { get }
    var parameters: [String: Any]? { get }
    var headers: HTTPHeaders? { get }
}

extension APIRequest {
    var parameters: [String: Any]? { nil }
    var headers: HTTPHeaders? { nil }
}

extension APIRequest {

    var urlRequest: URLRequest {

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = method.rawValue

        var mutableHeaders = request.allHTTPHeaderFields ?? [:]
        if let headers = headers {
            mutableHeaders.merge(headers) { _, new in new }
        }

        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true), let parameters = parameters {
            var mutableQueryItems = urlComponents.queryItems ?? []

            let queryItems: [URLQueryItem] = parameters.reduce([]) { results, parameter in
                var mutableResults = results

                if let arrayParam = parameter.value as? [Any] {
                    let arrayItems = arrayParam.map({ URLQueryItem(name: parameter.key, value: String(describing: $0)) })
                    mutableResults += arrayItems
                } else {
                    mutableResults.append(URLQueryItem(name: parameter.key, value: String(describing: parameter.value)))
                }

                return mutableResults
            }

            mutableQueryItems.append(contentsOf: queryItems)
            urlComponents.queryItems = !mutableQueryItems.isEmpty ? mutableQueryItems : nil
            if let newUrl = urlComponents.url {
                request.url = newUrl
            }
        }

        request.allHTTPHeaderFields = !mutableHeaders.isEmpty ? mutableHeaders : nil

        return request
    }
}

extension APIRequest {

    func formatPath(format: String, _ arguments: CVarArg...) -> Foundation.URL {

        let formattedPath = String(format: format, arguments: arguments)
        let url = APIClient.baseUrl.appendingPathComponent(formattedPath)
        return url
    }
}
