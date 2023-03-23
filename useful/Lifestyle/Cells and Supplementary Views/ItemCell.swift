//
//  ItemCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Kingfisher
import Lottie
import UIKit

final class ItemCell: UICollectionViewCell {

    // MARK: - Views

    private let nameLabel = UILabel.create(fontStyle: .headline, isDynamicallySized: true)
    private let itemImage = UIImageView.create()

    // MARK: - Overrides

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(collection: .selected) : UIColor(collection: .backgroundElevated)
        }
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        layer.applyShadow(blur: Constants.blur, spread: Constants.spread)
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        configureBorderIfNeeded()
    }

    // MARK: - Configurations

    private func configureBorderIfNeeded() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        contentView.layer.borderWidth = isDarkMode ? 1 : 0
        contentView.layer.borderColor = UIColor.separator.cgColor
    }

    private func configureUI() {
        configureBorderIfNeeded()
        layer.cornerRadius = Constants.cornerRadius
        backgroundColor = UIColor(collection: .backgroundElevated)

        mutate(contentView) {
            $0.layer.cornerRadius = Constants.cornerRadius
            $0.layer.applyShadow(blur: Constants.blur, spread: Constants.spread)
            $0.backgroundColor = UIColor(collection: .backgroundElevated)

            $0.addSubview(nameLabel)
            $0.addSubview(itemImage)
        }

        NSLayoutConstraint.snap(nameLabel, to: contentView, for: [.left, .right, .top], with: Constants.contentInsets)
        NSLayoutConstraint.snap(itemImage, to: contentView, for: [.bottom], with: Constants.contentInsets)
        NSLayoutConstraint.size(
            view: itemImage,
            attributes: [.height(value: Constants.imageSize.height), .width(value: Constants.imageSize.width)]
        )
        NSLayoutConstraint.center(itemImage, in: contentView, for: [.horizontal])
        itemImage.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: Constants.spacing).activate()
    }

    func configure(name: String, imageURL: String, imageURLDark: String, isCompleted: Bool) {
        nameLabel.text = name

        if let imageURL = traitCollection.userInterfaceStyle == .dark ? URL(string: imageURLDark) : URL(string: imageURL) {
            itemImage.kf.indicatorType = .custom(indicator: CustomIndicator())
            itemImage.kf.setImage(with: imageURL)
        }

        contentView.alpha = isCompleted ? 0.6 : 1.0
    }
}

extension ItemCell {
    enum Constants {
        static let contentInsets: UIEdgeInsets = .create(top: 24, right: 16, bottom: 36, left: 16)
        static let cornerRadius: CGFloat = 15
        static let imageSize = CGSize(width: 80, height: 70)
        static let spacing: CGFloat = 8
        static let spread: CGFloat = -20
        static let blur: CGFloat = 30
    }
}
