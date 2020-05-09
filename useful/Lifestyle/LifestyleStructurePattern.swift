//
//  StructurePattern.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

enum LifeStyleSection {
    case ongoing, completed, search
    
    var headerInfo: (title: String, annotation: String) {
        switch self {
        case .ongoing:
            return ("Mar 8 - Mar 14", "Current week")
        case .completed:
            return ("Completed items", .empty)
        case .search:
            return ("Search result items", .empty)
        }
    }
}

protocol LifestyleViewPresenter {
    
    var disposableItems: [(section: LifeStyleSection, items: [DisposableItem])] { get }
    
    init(view: LifestyleView)
    
    func loadItems(isReloading: Bool)
    func filterDisposableItems(query: String?)
}

protocol LifestyleView: class {
    
    func loadingDisposableItems(with info: LoadInfo)
    func refreshDisposableItems(animatingDifferences: Bool)
}
