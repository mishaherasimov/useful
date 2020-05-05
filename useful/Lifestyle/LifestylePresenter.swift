//
//  LifestylePresenter.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

class LifestylePresenter: LifestyleViewPresenter {
    
    var disposableItems: [[DisposableItem]] = []
    
    var loadState: LoadingState = .didLoad {
        didSet {
            view.loadingDisposableItems(with: loadState)
        }
    }
    
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
    
    // MARK: - API requests

    func loadItems() {

        loadState = .willLoad
        loadState = .isLoading

        APIClient().getDisposableItems { [weak self] response in

            guard let self = self else { return }
            
            guard let items = response.value else {
                
                let localizedMessage = NSLocalizedString("Something went wrong. Please try again later.", comment: "Message of alert presented on referrals load failure.")
                let localizedTitle = NSLocalizedString("Unable to load referrals.", comment: "Title of alert presented on raferrals load failure.")

                self.loadState = .failLoading(title: localizedTitle, message: localizedMessage)
                return
            }

            let completed = items.filter { $0.isCompleted == true }
            var active = items.filter { $0.isCompleted != true }
            
            // Add empty item to include suggestion item
            active.append(DisposableItem())
            
            self.disposableItems = [active, completed]
            self.loadState = .didLoad
        }
    }
}
