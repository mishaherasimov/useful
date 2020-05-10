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
    private let imageSize: CGSize = CGSize(width: 80, height: 70)
    private let spacing: CGFloat = 8
    private let spread: CGFloat = -20
    private let blur: CGFloat = 30
    
    // MARK: - Views
    
    private let nameLabel: UILabel = UILabel.create(fontStyle: .headline, isDynamicallySized: true)
    private let itemImage: UIImageView = UIImageView.create()
    
    // MARK: - Overrides
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(collection: .selected) : UIColor(collection: .backgroundElevated)
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        layer.applyShadow(blur: blur, spread: spread)
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
        
        layer.cornerRadius = cornerRadius
        backgroundColor = UIColor(collection: .backgroundElevated)
        
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.applyShadow(blur: blur, spread: spread)
        contentView.backgroundColor = UIColor(collection: .backgroundElevated)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(itemImage)
        
        NSLayoutConstraint.snap(nameLabel, to: contentView, for: [.left, .right, .top], with: contentInsets)
        NSLayoutConstraint.snap(itemImage, to: contentView, for: [.bottom], with: contentInsets)
        NSLayoutConstraint.size(view: itemImage, attributes: [.height(value: imageSize.height), .width(value: imageSize.width)])
        NSLayoutConstraint.center(itemImage, in: contentView, for: [.horizontal])
        itemImage.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: spacing).activate()
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
