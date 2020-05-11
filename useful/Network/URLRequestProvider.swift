//
//  URLRequestProvider.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-04.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

protocol URLRequestProvider: CustomStringConvertible {
    var urlRequest: URLRequest { get }
}
