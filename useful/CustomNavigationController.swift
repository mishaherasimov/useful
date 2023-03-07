//
//  UsefulNavigationController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = true

        mutate(UINavigationBarAppearance()) {
            $0.configureWithTransparentBackground()
            $0.titleTextAttributes = [.foregroundColor: UIColor.white]
            $0.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            $0.backgroundColor = UIColor(collection: .primary)

            navigationBar.standardAppearance = $0
            navigationBar.scrollEdgeAppearance = $0
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
