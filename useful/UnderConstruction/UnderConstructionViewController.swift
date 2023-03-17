//
//  UnderConstructionViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-06.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

final class UnderConstructionViewController: UIViewController {
    private enum Constants {
        static let closeButtonInsets: UIEdgeInsets = .create(top: 45, right: 32)
        static let closeButtonSize: CGFloat = 34
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        configureBlurView()
        configureEventView()
        configureCloseButton()
    }

    @objc
    private func close(_: UIButton) {
        dismiss(animated: true)
    }

    // MARK: Configurations

    private func configureBlurView() {

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView)
    }

    private func configureEventView() {

        let eventView = EventView(contentVerticalInset: 0)
        eventView.configure(for: .construction)
        view.addSubview(eventView)
        NSLayoutConstraint.snap(eventView, to: view)
    }

    private func configureCloseButton() {
        let closeButton = mutate(UIButton()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
            $0.tintColor = .white

            let configuration = UIImage.SymbolConfiguration(pointSize: Constants.closeButtonSize)
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
        }

        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Constants.closeButtonInsets.top
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Constants.closeButtonInsets.right
            ),
        ])
    }
}
