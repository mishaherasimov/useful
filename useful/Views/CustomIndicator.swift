//
//  AnimationView+Indicator.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-05.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Kingfisher
import Lottie

struct CustomIndicator: Indicator {
    
    let indicator: AnimationView = {
        let view = AnimationView(name: "loading")
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
    
    public func sizeStrategy(in imageView: KFCrossPlatformImageView) -> IndicatorSizeStrategy {
        return .size(.init(width: 50, height: 50))
    }
}
