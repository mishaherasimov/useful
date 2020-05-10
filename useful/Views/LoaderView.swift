//
//  LoaderView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-06.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit
import Lottie

class LoaderView: UIView {
    
    static let shared = LoaderView()
    
    private var sideConstraints: [NSLayoutConstraint] = []
    private let indicator: AnimationView = {
        let view = AnimationView(name: UITraitCollection.current.userInterfaceStyle == .dark ? "loading-dark" : "loading")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopMode = .loop
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        NSLayoutConstraint.snap(blurEffectView, to: self)
        
        addSubview(indicator)
        NSLayoutConstraint.size(view: indicator, attributes: [.height(value: 250), .width(value: 250)])
        NSLayoutConstraint.center(indicator, in: self)
    }
    
    func start(in view: UIView, configuration: (UIView) -> Void) {
        guard superview == nil else { return }
        configuration(self)
        let outerConstraints = NSLayoutConstraint.snap(self, to: view, for: [.left, .right, .bottom])
        let topConstraint = topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        sideConstraints = Array(outerConstraints.values) + [topConstraint]
        indicator.play()
    }
    
    func stop() {
        indicator.stop()
        removeConstraints(sideConstraints)
        removeFromSuperview()
    }
}
