//
//  UnderConstructionViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-06.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class UnderConstructionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView)
        
        let eventView = EventView()
        eventView.configure(for: .construction)
        view.addSubview(eventView)
        NSLayoutConstraint.snap(eventView, to: view)
    }
}
