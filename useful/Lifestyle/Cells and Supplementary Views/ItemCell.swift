//
//  ItemCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    // MARK: - Insets & constants
    
    private let contentInsets: UIEdgeInsets = .create(top: 24, right: 16, bottom: 36, left: 16)
    private let cornerRadius: CGFloat = 15
    private let spacing: CGFloat = 34
    private let spread: CGFloat = -20
    private let blur: CGFloat = 30
    
    // MARK: - Views
    
    private let nameLabel: UILabel = UILabel.create(fontStyle: .headline, isDynamicallySized: true)
    
    private let itemImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    // MARK: - Overrides
    
    override var isSelected: Bool {
        didSet {
//            backgroundColor = isSelected ? Theme.reddishColor : .white
//            floorLabel.textColor = isSelected ? .white : Theme.reddishColor
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
    
    func configure(name: String, image: UIImage?, isCompleted: Bool) {
        
        nameLabel.text = name
        itemImage.image = image
        contentView.alpha = isCompleted ? 0.6 : 1.0
    }
}
