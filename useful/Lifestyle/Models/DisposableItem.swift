//
//  DisposableItem.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

struct DisposableItem: Hashable, Equatable, Decodable {
    
    let name: String
    let imageURL: String
    let imageURLDark: String
    let isCompleted: Bool?
    
    init() {
        self.name = .empty
        self.imageURL = .empty
        self.isCompleted = nil
        self.imageURLDark = .empty
    }
}
