//
//  UIKit+CommonViewCreation.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

extension UIImageView {

    class func create(image: UIImage? = nil, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        mutate(UIImageView()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = image
            $0.contentMode = contentMode
        }
    }
}

extension UIView {

    class func create(backgroundColor: UIColor?, cornerRadius: CGFloat = 0) -> UIView {
        mutate(UIView()) {
            $0.layer.cornerRadius = cornerRadius
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = backgroundColor ?? .white
        }
    }

    func configureRequiredPriorities(for axis: [NSLayoutConstraint.PriorityAxis]) {

        axis.forEach {

            switch $0 {
            case .horizontal(let priority), .vertical(let priority):

                setContentHuggingPriority(priority, for: $0.constraintAxis)
                setContentCompressionResistancePriority(priority, for: $0.constraintAxis)
            }
        }
    }
}

extension UILabel {

    class func create(
        fontStyle: UIFont.TextStyle,
        fontTrait: UIFontDescriptor.SymbolicTraits? = nil,
        text: String? = nil,
        textColor: UIColor? = UIColor(collection: .label),
        textAlignment: NSTextAlignment = .left,
        isDynamicallySized: Bool = false,
        contentPriority axis: [NSLayoutConstraint.PriorityAxis] = []
    )
    -> UILabel {
        mutate(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.preferredFont(forTextStyle: fontStyle)
            $0.text = text
            $0.numberOfLines = isDynamicallySized ? 0 : 1
            $0.textAlignment = textAlignment
            $0.textColor = textColor
            $0.configureRequiredPriorities(for: axis)
            if let trait = fontTrait {
                $0.font = $0.font.withTraits(traits: trait)
            }
        }
    }
}

extension UIStackView {

    class func create(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 8,
        distribution: Distribution = .fill,
        alignment: Alignment = .fill
    )
    -> UIStackView {
        mutate(UIStackView()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.spacing = spacing
            $0.axis = axis
            $0.alignment = alignment
            $0.distribution = distribution
        }
    }

    var items: [UIView] {
        get {
            arrangedSubviews
        }
        set {
            arrangedSubviews.forEach { removeArrangedSubview($0) }
            newValue.forEach { addArrangedSubview($0) }
        }
    }
}
