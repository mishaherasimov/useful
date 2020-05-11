//
//  Colours+Convenience.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

extension UIColor {
    
    enum Collection: String {
        case background, primary, label, secondary, backgroundElevated, selected
    }
    
    convenience init?(collection: Collection) {
        self.init(named: collection.rawValue)
    }
}

