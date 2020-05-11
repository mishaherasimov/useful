//
//  CalendarAnimator.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-02.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class CalendarAnimator {
    
    private enum BoundsPosition {
        case mid, below(bound: CGFloat), above(bound: CGFloat, distance: CGFloat)
        
        var bound: CGFloat {
            switch self {
            case let .above(bound, _), let .below(bound):
                return bound
            default:
                return 0
            }
        }
        
        init(progress: CGFloat, translationY: CGFloat, bounds: (min: CGFloat, max: CGFloat)) {
            if progress > bounds.max {
                self = .above(bound: bounds.max, distance: abs(bounds.max - bounds.min))
            } else if progress < bounds.min, translationY <= 0 { // Movement in the negative direction and below the min threshold
                self = .below(bound: bounds.min)
            } else {
                self = .mid
            }
        }
        
        /// Calculates view translation after reaching bound
        /// - Parameter translation: Current translation
        /// - Returns: Final translation
        func rubberbandProgressCalculation(for translation: CGFloat) -> CGFloat {
            switch self {
            case let .above(_, distance):
                return logMaxConstraintValue(for: translation, distance: distance)
            case .below:
                return sqrtMinConstraintValue(for: translation)
            case .mid:
                return translation
            }
        }
        
        private func logMaxConstraintValue(for yPosition: CGFloat, distance: CGFloat) -> CGFloat {
            let total = distance + yPosition
            let translationRatio = distance == 0 ? total : total / distance
            return (distance * (1 + log10(translationRatio))) - distance
        }
        
        private func sqrtMinConstraintValue(for yPosition: CGFloat) -> CGFloat {
            let translation = abs(yPosition + abs(bound))
            return bound - sqrt(translation)
        }
    }
    
    private let constraint: NSLayoutConstraint
    private let bounds: (min: CGFloat, max: CGFloat)
    private var totalTranslation: CGFloat
    
    // -- Main animation properties --
    
    unowned var calendar: CalendarBar
    
    init(inset: CGFloat, constraint: NSLayoutConstraint, calendar: CalendarBar) {
        
        self.bounds = (inset, 0)
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
        let velocity = recognizer.velocity(in: calendar)
        let position = BoundsPosition(progress: constraint.constant, translationY: translation.y, bounds: bounds)
        
        switch position {
        case .below, .above:
            
            totalTranslation += translation.y
            constraint.constant = position.rubberbandProgressCalculation(for: totalTranslation)
            if (recognizer.state == .ended) {
                animateView(to: position.bound, velocity: velocity.y)
            }
        case .mid:
            
            totalTranslation = translation.y > 0 ? bounds.max : bounds.min
            
            switch recognizer.state {
            case .ended:
                let decelerationRate = UIScrollView().decelerationRate
                let projectedPosition = constraint.constant + project(initialVelocity: velocity.y, decelerationRate: decelerationRate.rawValue)
                let projectedBound = nearestBound(to: projectedPosition)
                
                animateView(to: projectedBound, velocity: velocity.y)
            default:
                constraint.constant += translation.y
            }
        }
        
        recognizer.setTranslation(.zero, in: calendar)
    }
    
    // -- Helper functions --
    
    private func nearestBound(to position: CGFloat) -> CGFloat {
        let midPoint = (bounds.max - bounds.min) / 2
        return -1 * midPoint < position ? bounds.max : bounds.min
    }
    
    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
    // -- Animator --
    
    private func animateView(to bound: CGFloat, velocity: CGFloat) {
        
        let normalizedVelocity = velocity / abs(bounds.max - bounds.min)
        
        let timing = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: normalizedVelocity))
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
        
        animator.addAnimations {
            
            self.constraint.constant = bound
            self.calendar.superview?.layoutIfNeeded()
            self.totalTranslation = bound
        }
        
        animator.startAnimation()
    }
    
    // -- Action --
    
    func closeBar() {
        guard constraint.constant == bounds.max else { return }
        animateView(to: bounds.min, velocity: 10)
    }
}
