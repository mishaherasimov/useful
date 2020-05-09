//
//  UnderConstructionViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-06.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class UnderConstructionViewController: UIViewController {
    
    private let closeButtonInsets: UIEdgeInsets = .create(top: 45, right: 32)
    private let closeButtonSize: CGFloat = 34

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
    
        configureBlurView()
        configureEventView()
        configureCloseButton()
    }
    
    @objc private func close(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Configurations
    
    private func configureBlurView() {
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView)
    }
    
    private func configureEventView() {
        
        let eventView = EventView(contentVerticalInset: 0, textColor: traitCollection.userInterfaceStyle == .dark ? .white : UIColor(collection: .midnightBlack))
        eventView.configure(for: .construction)
        view.addSubview(eventView)
        NSLayoutConstraint.snap(eventView, to: view)
    }
    
    private func configureCloseButton() {
        
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        closeButton.tintColor = .white
        
        let configuration = UIImage.SymbolConfiguration(pointSize: closeButtonSize)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration), for: .normal)
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: closeButtonInsets.top),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -closeButtonInsets.right)
        ])
    }
}
