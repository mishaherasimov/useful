//
//  CalendarItemCell.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class CalendarItemCell: UICollectionViewCell {

    // MARK: - Views

    private let dayLabel = UILabel.create(fontStyle: .caption1, textColor: .white, textAlignment: .center)

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

        contentView.addSubview(dayLabel)
        backgroundColor = .clear
        NSLayoutConstraint.snap(dayLabel, to: contentView)
    }

    func configure(day: Int, isCurrentMonth: Bool) {

        dayLabel.text = String(day)
        contentView.alpha = isCurrentMonth ? 1.0 : 0.5
    }
}
