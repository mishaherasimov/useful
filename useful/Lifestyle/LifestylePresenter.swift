//
//  LifestylePresenter.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

class LifestylePresenter: LifestyleViewPresenter {

    private var currentWeek: (week: Int, date: Date)?

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

    required init(view: LifestyleView) {

        self.view = view
    }

    // API requests

    func loadItems(isReloading: Bool, selectedWeek: (week: Int, date: Date)?) {

        currentWeek = selectedWeek ?? currentWeek
        guard let week = currentWeek?.week else { return }

        let type: LoadingType = isReloading ? .fullReload : .loadNew

        loadInfo = (.willLoad, type)
        loadInfo = (.isLoading, type)

        APIClient().getDisposableItems(week: week) { [weak self] response in

            guard let self = self else { return }

            guard let values = response.value else {

                self.loadInfo = (.failLoading, type)
                return
            }

            let items = values.sorted { $0.key > $1.key }.map { $0.value }
            let completed = items.filter { $0.isCompleted == true }
            var active = items.filter { $0.isCompleted != true }

            // Add empty item to include suggestion item
            if !active.isEmpty { active.append(DisposableItem()) }

            self.originalItems = [active, completed].filter { !$0.isEmpty }
            self.loadInfo = (.didLoad, type)
        }
    }

    // Search

    func filterDisposableItems(query: String?) {

        guard let query = query, !query.isEmpty else {
            let sections: [LifeStyleSection] = [.ongoing, .completed]
            let subsections = Array(sections[0..<originalItems.indices.upperBound])

            disposableItems = !originalItems.isEmpty ? Array(zip(subsections, originalItems)) : []
            return
        }

        let items = originalItems.flatMap { $0 }
        let filteredItems = items.filter { $0.name.lowercased().contains(query.lowercased()) }
        disposableItems = !filteredItems.isEmpty ? [(.search, filteredItems)] : []
    }

    // -- Search --

    func header(for section: LifeStyleSection) -> (title: String, annotation: String) {

        switch section {
        case .ongoing:
            guard
                let date = currentWeek?.date,
                let endOfweek = date.endOfWeek?.formatted(as: .custom(style: .weekDay, timeZone: .current)),
                let startOfweek = date.startOfWeek?.formatted(as: .custom(style: .weekDay, timeZone: .current))
            else { return (.empty, .empty) }
            let weekInfo = String(format: "%@ - %@", startOfweek, endOfweek)
            return (weekInfo, "Current week")
        case .completed:
            return ("Completed items", .empty)
        case .search:
            return ("Search result items", .empty)
        }
    }
}
