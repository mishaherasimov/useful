//
//  LegendSupplementaryView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-30.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class LegendSupplementaryView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureUI()
    }
    
    private func configureUI() {
        
        let stackView = UIStackView.create(axis: .horizontal, spacing: 0, distribution: .fillEqually)
        addSubview(stackView)
        
        backgroundColor = .clear
        
        let legends = Calendar.current.veryShortWeekdaySymbols.map {
            UILabel.create(fontStyle: .subheadline, text: $0, textColor: .white, textAlignment: .center)
        }
        
        stackView.items = legends
        NSLayoutConstraint.snap(stackView, to: self)
    }
}
