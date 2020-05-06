//
//  ItemCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit
import Kingfisher
import Lottie

class ItemCell: UICollectionViewCell {
    
    // MARK: - Insets & constants
    
    private let contentInsets: UIEdgeInsets = .create(top: 24, right: 16, bottom: 36, left: 16)
    private let cornerRadius: CGFloat = 15
    private let spacing: CGFloat = 34
    private let spread: CGFloat = -20
    private let blur: CGFloat = 30
    
    // MARK: - Views
    
    private let nameLabel: UILabel = UILabel.create(fontStyle: .headline, isDynamicallySized: true)
    private let itemImage: UIImageView = UIImageView.create()
    
    // MARK: - Overrides
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(collection: .dirtySand) : .white
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureUI()
    }
    
    // MARK: - Configurations
    
    private func configureUI() {
        
        let stackView = UIStackView.create(axis: .vertical, spacing: spacing)
        contentView.addSubview(stackView)
        
        layer.cornerRadius = cornerRadius
        layer.applyShadow(blur: blur, spread: spread)
        backgroundColor = .white
        
        stackView.items = [nameLabel, itemImage]
        NSLayoutConstraint.snap(stackView, to: contentView, with: contentInsets)
    }
    
    func configure(name: String, imageURL: String, isCompleted: Bool) {
        
        nameLabel.text = name
        
        if let imageURL = URL(string: imageURL) {
            itemImage.kf.indicatorType = .custom(indicator: CustomIndicator())
            itemImage.kf.setImage(with: imageURL)
        }

        contentView.alpha = isCompleted ? 0.6 : 1.0
    }
}
