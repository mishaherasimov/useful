//
//  NetworkSessionManager.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

final class NetworkSessionManager: NSObject {

    let session: URLSession

    override init() {
        session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
    }

    @discardableResult
    public func data(_ request: URLRequestProvider, completionBlock: @escaping (DataResponse) -> Void) -> URLSessionDataTask {

        let urlRequest = request.urlRequest

        let task = session.dataTask(with: urlRequest) { data, response, error in
            let dataResponse = DataResponse(request: urlRequest, response: response as? HTTPURLResponse, data: data, error: error)
            DispatchQueue.main.async {
                completionBlock(dataResponse)
            }
        }

        task.resume()

        return task
    }
}
