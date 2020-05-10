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
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = contentMode
        return imageView
    }
}

extension UIView {
    
    class func create(backgroundColor: UIColor?, cornerRadius: CGFloat = 0) -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor ?? .white
        return view
    }
    
    func configureRequiredPriorities(for axies: [NSLayoutConstraint.PriorityAxis]) {

        axies.forEach {

            switch $0 {
            case let .horizontal(priority), let .vertical(priority):

                setContentHuggingPriority(priority, for: $0.constraintAxis)
                setContentCompressionResistancePriority(priority, for: $0.constraintAxis)
            }
        }
    }
}

extension UILabel {

    class func create(fontStyle: UIFont.TextStyle,
                      fontTrait: UIFontDescriptor.SymbolicTraits? = nil,
                      text: String? = nil,
                      textColor: UIColor? = UIColor(collection: .label),
                      textAlignment: NSTextAlignment = .left,
                      isDynamicallySized: Bool = false,
                      contentPriority axies: [NSLayoutConstraint.PriorityAxis] = []) -> UILabel {

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: fontStyle)
        label.text = text
        label.numberOfLines = isDynamicallySized ? 0 : 1
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.configureRequiredPriorities(for: axies)
        
        if let trait = fontTrait {
            label.font = label.font.withTraits(traits: trait)
        }
        
        return label
    }
}

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
