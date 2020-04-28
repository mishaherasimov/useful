//
//  LifestylePresenter.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

class LifestylePresenter: LifestyleViewPresenter {
    
    var disposableItems: [[DisposableItem]] = {
        var allItems = DisposableItem.generateItems()
        let lastItem = allItems.removeLast()
        return [allItems, [lastItem]]
    }()
    
    unowned let view: LifestyleView
    
    // MARK: - Initializers
    
    required init(view: LifestyleView) {
        
        self.view = view
    }
    
    func header(for section: LifestyleViewController.Section) -> (title: String, annotation: String) {
        
        switch section {
        case .ongoing:
            return ("Mar 8 - Mar 14", "Current week")
        case .completed:
            return ("Completed items", .empty)
        }
    }
}
