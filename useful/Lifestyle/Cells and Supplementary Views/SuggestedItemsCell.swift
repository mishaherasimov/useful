//
//  SuggestedItemsCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class SuggestedItemsCell: UICollectionViewCell {
    // MARK: - Insets & constants
    
    private let contentInsets: UIEdgeInsets = .create(top: 24, right: 12, bottom: 14, left: 16)
    private let cornerRadius: CGFloat = 15
    private let spacing: CGFloat = 19
    private let spread: CGFloat = -20
    private let blur: CGFloat = 30
    
    // MARK: - Views
    private let disclosureImageView: UIImageView = {
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold, scale: .medium)
        let symbol = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: symbolConfig)
        let imageView = UIImageView(image: symbol)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let itemsLabel: UILabel = UILabel.create(fontStyle: .largeTitle,
                                                     fontTrait: .traitBold,
                                                     textColor: .white,
                                                     contentPriority: [.vertical])
    private let annotationLabel: UILabel = UILabel.create(fontStyle: .headline,
                                                          text: "Suggestions based on your current progress",
                                                          textColor: .white,
                                                          isDynamicallySized: true)
    
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
        contentView.addSubview(disclosureImageView)
        
        layer.cornerRadius = cornerRadius
        layer.applyShadow(color: UIColor(collection: .marsh), blur: blur, spread: spread)
        backgroundColor = UIColor(collection: .marsh)
        
        stackView.items = [annotationLabel, itemsLabel]
        NSLayoutConstraint.snap(stackView, to: contentView, with: contentInsets)
        
        NSLayoutConstraint.activate([
            disclosureImageView.bottomAnchor.constraint(equalTo: itemsLabel.topAnchor),
            disclosureImageView.trailingAnchor.constraint(equalTo: itemsLabel.trailingAnchor)
        ])
    }
    
    func configure(items: Int) {
        
        itemsLabel.text = String(format: "%d items", items)
    }
}
