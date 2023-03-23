//
//  TitleSupplementaryView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView {

    // MARK: - Insets & constants

    private let spacing: CGFloat = 10

    // MARK: - Views

    private let titleLabel = UILabel.create(fontStyle: .title2, fontTrait: .traitBold)
    private let annotationLabel = UILabel.create(fontStyle: .footnote, textColor: UIColor.secondaryLabel)

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureUI()
    }

    // MARK: - Configurations

    private func configureUI() {
        let stackView = UIStackView.create(axis: .vertical, spacing: spacing)
        addSubview(stackView)

        backgroundColor = .clear

        stackView.items = [annotationLabel, titleLabel]
        NSLayoutConstraint.snap(stackView, to: self)
    }

    func configure(header: (title: String, annotation: String)) {
        annotationLabel.isHidden = header.annotation.isEmpty
        titleLabel.text = header.title
        annotationLabel.text = header.annotation
    }
}
