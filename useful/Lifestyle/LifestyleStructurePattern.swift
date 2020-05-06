//
//  StructurePattern.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

protocol LifestyleViewPresenter {
    
    var disposableItems: [[DisposableItem]] { get }
    
    init(view: LifestyleView)
    
    func header(for section: LifestyleViewController.Section) -> (title: String, annotation: String)
    func loadItems(isReloading: Bool)
}

protocol LifestyleView: class {
    
    func loadingDisposableItems(with info: LoadInfo)
}
