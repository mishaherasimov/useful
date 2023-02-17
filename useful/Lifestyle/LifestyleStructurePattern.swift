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
}

protocol LifestyleViewPresenter {
    
    var disposableItems: [(section: LifeStyleSection, items: [DisposableItem])] { get }
    
    init(view: LifestyleView)
    
    func header(for section: LifeStyleSection) -> (title: String, annotation: String)
    
    func loadItems(isReloading: Bool, selectedWeek: (week: Int, date: Date)?)
    func filterDisposableItems(query: String?)
}

protocol LifestyleView: AnyObject {
    
    func loadingDisposableItems(with info: LoadInfo)
    func refreshDisposableItems(animatingDifferences: Bool)
}
