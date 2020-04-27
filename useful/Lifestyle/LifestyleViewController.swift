//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class LifestyleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "olive")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
