//
//  DisposableItem.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

struct DisposableItem: Hashable, Equatable {
    
    let title: String
    let imageName: String
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}

extension DisposableItem {
    static func generateItems() -> [DisposableItem] {
        return [
            DisposableItem(title: "Plastic razor", imageName: "razor"),
            DisposableItem(title: "Plastic bottle", imageName: "bottle"),
            DisposableItem(title: "Plastic bag", imageName: "bag"),
            DisposableItem(title: .empty, imageName: .empty),
            DisposableItem(title: "Non-recyclable toothbrush", imageName: "brash")
        ]
    }
}
