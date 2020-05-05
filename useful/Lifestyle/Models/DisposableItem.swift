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
    let isCompleted: Bool?
    
    var image: UIImage? {
        return UIImage(named: "bag")
    }
    
    init() {
        self.name = .empty
        self.imageURL = .empty
        self.isCompleted = nil
    }
}
