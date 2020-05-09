//
//  LifestylePresenter.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

class LifestylePresenter: LifestyleViewPresenter {
    
    private var originalItems: [[DisposableItem]] = [] {
        didSet {
            filterDisposableItems(query: nil)
        }
    }
    
    private var loadInfo: LoadInfo = (.didLoad, .fullReload) {
        didSet {
            view.loadingDisposableItems(with: loadInfo)
        }
    }
    
    var disposableItems: [(section: LifeStyleSection, items: [DisposableItem])] = [] {
        didSet {
            view.refreshDisposableItems(animatingDifferences: true)
        }
    }
    
    
    unowned let view: LifestyleView
    
    // MARK: - Initializers
    
    required init(view: LifestyleView) {
        
        self.view = view
    }
    
    // MARK: - API requests
    
    func loadItems(isReloading: Bool) {
        
        let type: LoadingType = isReloading ? .fullReload : .loadNew
        
        loadInfo = (.willLoad, type)
        loadInfo = (.isLoading, type)
        
        APIClient().getDisposableItems { [weak self] response in
        
            guard let self = self else { return }
            
            guard let items = response.value else {
                
                self.loadInfo = (.failLoading, type)
                return
            }
            
            let completed = items.filter { $0.isCompleted == true }
            var active = items.filter { $0.isCompleted != true }
            
            // Add empty item to include suggestion item
            active.append(DisposableItem())
            
            self.originalItems = [active, completed]
            self.loadInfo = (.didLoad, type)
        }
    }
    
    // MARK: - Search
    
    func filterDisposableItems(query: String?) {
        
        guard let query = query, !query.isEmpty else {
            let sections: [LifeStyleSection] = [.ongoing, .completed]
            disposableItems = originalItems.count == 2 ? Array(zip(sections, originalItems)) : []
            return
        }
        
        let items = originalItems.flatMap({ $0 })
        let filteredItems = items.filter { $0.name.lowercased().contains(query.lowercased()) }
        disposableItems = !filteredItems.isEmpty ? [(.search, filteredItems)] : []
    }
}
