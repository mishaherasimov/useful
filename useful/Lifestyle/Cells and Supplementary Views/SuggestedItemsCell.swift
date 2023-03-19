//
//  SuggestedItemsCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

final class SuggestedItemsCell: UICollectionViewCell {

    // MARK: - Views

    private let disclosureImageView: UIImageView = {

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold, scale: .medium)
        let symbol = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: symbolConfig)
        let imageView = UIImageView(image: symbol)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let itemsLabel = UILabel.create(
        fontStyle: .largeTitle,
        fontTrait: .traitBold,
        textColor: .white,
        contentPriority: [.vertical]
    )
    private let annotationLabel = UILabel.create(
        fontStyle: .headline,
        text: "Suggestions based on your current progress",
        textColor: .white,
        isDynamicallySized: true
    )

    private let itemImage: UIImageView = mutate(UIImageView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .center
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

        let stackView = UIStackView.create(axis: .vertical, spacing: Constants.spacing)
        contentView.addSubview(stackView)
        contentView.addSubview(disclosureImageView)

        layer.cornerRadius = Constants.cornerRadius
        layer.applyShadow(color: UIColor(collection: .secondary), blur: Constants.blur, spread: Constants.spread)
        backgroundColor = UIColor(collection: .secondary)

        stackView.items = [annotationLabel, itemsLabel]
        NSLayoutConstraint.snap(stackView, to: contentView, with: Constants.contentInsets)

        NSLayoutConstraint.activate([
            disclosureImageView.bottomAnchor.constraint(equalTo: itemsLabel.topAnchor),
            disclosureImageView.trailingAnchor.constraint(equalTo: itemsLabel.trailingAnchor),
        ])
    }

    func configure(items: Int) {

        itemsLabel.text = String(format: "%d items", items)
    }
}

extension SuggestedItemsCell {
    enum Constants {
        static let contentInsets: UIEdgeInsets = .create(top: 24, right: 12, bottom: 14, left: 16)
        static let cornerRadius: CGFloat = 15
        static let spacing: CGFloat = 19
        static let spread: CGFloat = -20
        static let blur: CGFloat = 30
    }
}
