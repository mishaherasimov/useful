//
//  CalendarAnimator.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-02.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class CalendarAnimator {
    
    private let constraint: NSLayoutConstraint
    private let bounds: (min: CGFloat, max: CGFloat)
    
    private var totalTranslation: CGFloat
    
    unowned var calendar: CalendarBar
    
    init(bounds: (min: CGFloat, max: CGFloat), constraint: NSLayoutConstraint, calendar: CalendarBar) {
        
        self.bounds = bounds
        self.totalTranslation = bounds.max
        self.constraint = constraint
        self.calendar = calendar
        
        configure()
    }
    
    private func configure() {
        
        // -- Recognizers --
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handle(recognizer:)))
        calendar.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handle(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: calendar)
        
        if constraint.constant > bounds.max {
            
            totalTranslation += translation.y
            constraint.constant = logConstraintValue(for: totalTranslation)
            if(recognizer.state == .ended ){
                animateViewBackToLimit()
            }
            
        } else {
            constraint.constant += translation.y
        }
        recognizer.setTranslation(.zero, in: calendar)
        
        
        
        
        //        guard let constraint = heightConstraint, recognizer.state == .changed else { return }
        //
        //        let translation = recognizer.translation(in: self)
        //
        //        if 35...280 ~= constraint.constant {
        //
        //            constraint.constant += translation.y
        //            recognizer.setTranslation(.zero, in: self)
        //        }
        //        print(constraint.constant)
        
        //        print(translation.y)
    }
    
    func logConstraintValue(for yPosition: CGFloat) -> CGFloat {
        return bounds.max * (1 + log10(yPosition/bounds.max))
    }
    
    func animateViewBackToLimit() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.constraint.constant = self.bounds.max
            self.calendar.layoutIfNeeded()
            self.totalTranslation = 280
            
        }, completion: nil)
    }
}
