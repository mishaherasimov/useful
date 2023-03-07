//
//  AnimationView+Indicator.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Kingfisher
import Lottie
import UIKit

struct CustomIndicator: Indicator {

    let indicator: LottieAnimationView = {
        let view = LottieAnimationView(
            name: UITraitCollection.current.userInterfaceStyle == .dark
                ? "image-loading-dark"
                : "image-loading"
        )
        view.loopMode = .loop
        return view
    }()

    public func startAnimatingView() {
        indicator.isHidden = false
        indicator.play()
    }

    public func stopAnimatingView() {
        indicator.stop()
        indicator.isHidden = true
    }

    public var view: IndicatorView {
        return indicator
    }

    public func sizeStrategy(in _: KFCrossPlatformImageView) -> IndicatorSizeStrategy {
        return .size(.init(width: 100, height: 100))
    }
}
