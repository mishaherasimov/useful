//
//  WeekBackgroundDecorationView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-30.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class WeekBackgroundDecorationView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 16
    }
}
