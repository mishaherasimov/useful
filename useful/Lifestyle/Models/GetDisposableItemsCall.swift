//
//  GetDisposableItemsCall.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

struct GetDisposableItemsCall {
    let week: Int
}

extension GetDisposableItemsCall: APIParser {
    typealias DecodableType = [String: DisposableItem]
}

extension GetDisposableItemsCall: APIRequest {

    var method: HTTPMethod {
        .get
    }

    var url: URL {
        formatPath(format: "disposables.json")
    }

    var parameters: [String: Any]? {
        ["orderBy": "\"week\"", "equalTo": week]
    }
}

extension APIClient {

    func getDisposableItems(week: Int, _ completion: @escaping (APIResponse<[String: DisposableItem]>) -> Void) {
        let call = GetDisposableItemsCall(week: week)

        sessionManager.data(call) { response in
            self.handleResponse(call, response: response, completionHandler: completion)
        }
    }
}
