//
//  UIFont+Traits.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

extension UIFont {

    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { fatalError("Cannot get font descriptor") }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
