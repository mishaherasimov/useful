//
//  CalendarAnimator.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-02.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

protocol CalendarAnimatorDelegate: class {
    func didUpdateInset(to inset: CGFloat)
}

class CalendarAnimator {
    
    private enum State {
        case closed
        case open
        
        func toggle() -> State {
            switch self {
            case .open:
                return .closed
            case .closed:
                return .open
            }
        }
    }
    
    private enum BoundsPosition {
        case mid, below(bound: CGFloat), above(bound: CGFloat)
        
        var bound: CGFloat {
            switch self {
            case let .above(bound), let .below(bound):
                return bound
            default:
                return 0
            }
        }
        
        init(progress: CGFloat, translationY: CGFloat, bounds: (min: CGFloat, max: CGFloat)) {
            if progress > bounds.max {
                self = .above(bound: bounds.max)
            } else if progress < bounds.min, translationY <= 0 { // Movement in the negative direction and below the min threshold
                self = .below(bound: bounds.min)
            } else {
                self = .mid
            }
        }
        
        func rubberbandProgressCalculation(for translation: CGFloat) -> CGFloat {
            switch self {
            case .above:
                return logMaxConstraintValue(for: translation)
            case .below:
                return sqrtMinConstraintValue(for: translation)
            case .mid:
                return translation
            }
        }
        
        private func logMaxConstraintValue(for yPosition: CGFloat) -> CGFloat {
//            return bound * (1 + log10(yPosition / bound))
//            return (1 + log10(yPosition))
            return bound + sqrt(bound + yPosition)
        }
        
        private func sqrtMinConstraintValue(for yPosition: CGFloat) -> CGFloat {
            return bound - sqrt(abs(yPosition))
        }
    }
    
    private let constraint: NSLayoutConstraint
    private let bounds: (min: CGFloat, max: CGFloat)
    
    private var totalTranslation: CGFloat
    
    // Main animation properties
    
    private var currentState: State = .closed
    private var runningAnimator: UIViewPropertyAnimator?
    private var animationProgress: CGFloat = 0
    
    // -- Main animation properties --
    
    weak var delegate: CalendarAnimatorDelegate?
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
        
        let panRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(self.handle(recognizer:)))
        calendar.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handle(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: calendar)
        print(constraint.constant)
        let position = BoundsPosition(progress: constraint.constant, translationY: translation.y, bounds: bounds)
print(position)
        switch position {
        case .below, .above:

            totalTranslation += translation.y
            constraint.constant = position.rubberbandProgressCalculation(for: totalTranslation)
            if(recognizer.state == .ended) {
                animateViewBackToLimit(bound: position.bound, initialVelocity: CGVector(dx: 0, dy: 10))
            }
            recognizer.setTranslation(.zero, in: calendar)
        case .mid:
//
            totalTranslation = translation.y > 0 ? bounds.max : bounds.min
//            constraint.constant += translation.y
        
        switch recognizer.state {
        case .began:

                // start the animations
                animateTransitionIfNeeded(to: currentState.toggle(), duration: 0.5)

                // pause animation, since the next event may be a pan changed
                runningAnimator?.pauseAnimation()

                // keep track of each animator's progress
                animationProgress = runningAnimator?.fractionComplete ?? 0

            case .changed:

                // variable setup
                var fraction = translation.y / (bounds.max - bounds.min)
//                print("Fraction \(fraction), translation \(translation.y), the bounds: \((bounds.max - bounds.min))")

                // adjust the fraction for the current state and reversed state
                if currentState == .open { fraction *= -1 }
                if runningAnimator?.isReversed == true { fraction *= -1 }

                // apply the new fraction
                runningAnimator?.fractionComplete = fraction + animationProgress
                print(fraction + animationProgress)

            case .ended:

                // variable setup
                let yVelocity = recognizer.velocity(in: calendar).y
                let shouldClose = yVelocity < 0

                // if there is no motion, continue all animations and exit early
                if yVelocity == 0 {
                    runningAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }

                // reverse the animations based on their current state and pan motion
                switch currentState {
                case .open:
                    if !shouldClose, let animator = runningAnimator, !animator.isReversed { animator.isReversed = !animator.isReversed }
                    if shouldClose, let animator = runningAnimator, animator.isReversed { animator.isReversed = !animator.isReversed }
                case .closed:
                    if shouldClose, let animator = runningAnimator, !animator.isReversed { animator.isReversed = !animator.isReversed }
                    if !shouldClose, let animator = runningAnimator, animator.isReversed { animator.isReversed = !animator.isReversed }
                }

                // continue animation
                runningAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)

            default:
                ()
            }
        }
    }
    
    private func animateViewBackToLimit(bound: CGFloat, initialVelocity: CGVector) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 10,
                       options: .allowUserInteraction, animations: {
                        
                        self.constraint.constant = bound
                        self.calendar.superview?.layoutIfNeeded()
                        self.totalTranslation = bound
        })
        
        //        let timing = UISpringTimingParameters(damping: 1, response: 2, initialVelocity: initialVelocity) //(dampingRatio: 0.9, initialVelocity: 10)
        //        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
        //
        //        animator.addAnimations {
        //            self.calendar.layoutIfNeeded()
        //        }
        //
        //        animator.addCompletion { _ in
        //            self.totalTranslation = bound
        //        }
        //
        //        self.constraint.constant = self.bounds.max
        //        animator.startAnimation()
    }
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        guard runningAnimator == nil else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.constraint.constant = self.bounds.max
            case .closed:
                self.constraint.constant = self.bounds.min
            }
            self.calendar.superview?.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
            case .start:
                self.currentState = state.toggle()
            case .end:
                self.currentState = state
            default:
                break
            }
            
            // manually reset the constraint positions
            switch self.currentState {
            case .open:
                self.constraint.constant = self.bounds.max
            case .closed:
                self.constraint.constant = self.bounds.min
            }
            
            // remove running animator
            self.runningAnimator = nil
            self.delegate?.didUpdateInset(to: self.currentState == .open ? self.bounds.max : self.bounds.min)
        }
        
        // start animator
        transitionAnimator.startAnimation()
        
        // keep track of running animator
        runningAnimator = transitionAnimator
    }
}

private extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
}
