//
//  EvenView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class EventView: UIView {

    enum EventType {
        case empty, error, construction
    }

    private let contentSpacing: CGFloat = 16
    private let imageViewWidth: CGFloat = 245
    private var verticalInset: CGFloat

    private let imageView = UIImageView.create()
    private let contentLabel = UILabel.create(fontStyle: .subheadline, textAlignment: .center)

    convenience init(contentVerticalInset: CGFloat) {
        self.init(frame: .zero)
        verticalInset = contentVerticalInset
    }

    override init(frame: CGRect) {
        verticalInset = 0
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {

        translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView.create(axis: .vertical, spacing: contentSpacing)
        stackView.items = [imageView, contentLabel]

        addSubview(stackView)

        NSLayoutConstraint.center(stackView, in: self, for: [.vertical, .horizontal], with: CGPoint(x: 0, y: -verticalInset))
    }

    func configure(for type: EventType) {

        switch type {
        case .construction:
            imageView.image = #imageLiteral(resourceName: "under-construction")
            contentLabel.text = "It Is under Construction"
        case .empty:
            imageView.image = #imageLiteral(resourceName: "the-list-is-empty")
            contentLabel.text = "No Items Have Been Found"
        case .error:
            imageView.image = #imageLiteral(resourceName: "fatal-error")
            contentLabel.text = "An Error Occurred. Try to Refresh Content"
        }
    }
}
