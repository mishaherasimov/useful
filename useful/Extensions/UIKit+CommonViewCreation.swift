//
//  UIKit+CommonViewCreation.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

extension UIStackView {

    class func create(axis: NSLayoutConstraint.Axis, spacing: CGFloat = 8, distribution: Distribution = .fill, alignment: Alignment = .fill) -> UIStackView {

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = spacing
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        return stackView
    }

    var items: [UIView] {
        set {
            arrangedSubviews.forEach { removeArrangedSubview($0) }
            newValue.forEach { addArrangedSubview($0) }
        }
        get {
            return arrangedSubviews
        }
    }
}
