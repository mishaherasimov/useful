//
//  GetDisposableItemsCall.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

struct GetDisposableItemsCall {}

extension GetDisposableItemsCall: APIParser {
    typealias DecodableType = [DisposableItem]
}

extension GetDisposableItemsCall: APIRequest {

    var method: HTTPMethod {
        return .get
    }

    var url: URL {
        return formatPath(format: "disposables.json")
    }
}

extension APIClient {

    func getDisposableItems(_ completion: @escaping (APIResponse<[DisposableItem]>) -> Void) {
        let call = GetDisposableItemsCall()

        sessionManager.data(call) { response in
            self.handleResponse(call, response: response, completionHandler: completion)
        }
    }
}
