//
//  LifestylePresenter.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-28.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Combine
import ComposableArchitecture
import Foundation

enum LifestyleSectionType {
    case ongoing, completed, search
}

struct LifestyleSection: Equatable {
    var section: LifestyleSectionType
    var items: [DisposableItem]
}

struct Week: Equatable {
    let week: CalendarBar.Week
    let date: Date

    init(_ week: CalendarBar.Week, _ date: Date) {
        self.week = week
        self.date = date
    }
}

extension LifestyleFeature.State {
    func header(for section: LifestyleSectionType) -> (title: String, annotation: String) {

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

struct LifestyleFeature: ReducerProtocol {
    struct State: Equatable {
        var currentWeek: Week?
        var loadInfo: LoadInfo
        var originalItems: [[DisposableItem]]
        var disposableItems: [LifestyleSection]
    }

    enum Action {
        case onViewDidLoad
        case refreshControlTriggered
        case onSelectedWeek(Week)
        case filterQueryChanged(query: String?)

        case didLoadItems(APIResponse<[String: DisposableItem]>, type: LoadingType)
        case onLoadContent(isReloading: Bool, weekInfo: Week?)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.mainQueue) var mainQueue

    private enum RefreshCompletionID {}

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onLoadContent(let isReloading, let weekInfo):

                state.currentWeek = weekInfo ?? state.currentWeek
                guard let week = state.currentWeek?.week else { return .none }

                let type: LoadingType = isReloading ? .fullReload : .loadNew

                state.loadInfo = .init(.willLoad, type)
                state.loadInfo = .init(.isLoading, type)

                let valuePublisher = PassthroughSubject<APIResponse<[String: DisposableItem]>, Never>()

                apiClient.getDisposableItems(week: week.rawValue) {
                    valuePublisher.send($0)
                }

                return valuePublisher
                    .map { Action.didLoadItems($0, type: type) }
                    .eraseToEffect()
            case .onViewDidLoad:

                return .send(.onLoadContent(isReloading: false, weekInfo: .init(.week1, Date())))
            case .didLoadItems(let response, let loadType):
                guard let values = response.value else {

                    state.loadInfo = .init(.failLoading, loadType)
                    return .none
                }

                let items = values.sorted { $0.key > $1.key }.map { $0.value }
                let completed = items.filter { $0.isCompleted == true }
                var active = items.filter { $0.isCompleted != true }

                // Add empty item to include suggestion item
                if !active.isEmpty { active.append(DisposableItem()) }

                state.originalItems = [active, completed].filter { !$0.isEmpty }
                state.loadInfo = .init(.didLoad, loadType)

                return .send(.filterQueryChanged(query: nil))
            case .refreshControlTriggered:

                return Just(Action.onLoadContent(isReloading: true, weekInfo: nil))
                    .delay(for: 0.5, scheduler: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: RefreshCompletionID.self, cancelInFlight: true)
            case .onSelectedWeek(let week):

                return .send(.onLoadContent(isReloading: false, weekInfo: week))
            case .filterQueryChanged(query: let query):

                guard let query = query, !query.isEmpty else {
                    let sections: [LifestyleSectionType] = [.ongoing, .completed]
                    let subsections = Array(sections[0..<state.originalItems.indices.upperBound])

                    if !state.originalItems.isEmpty {
                        state.disposableItems = zip(subsections, state.originalItems).map { section, items in
                            LifestyleSection(section: section, items: items)
                        }
                    } else {
                        state.disposableItems = []
                    }

                    return .none
                }

                let items = state.originalItems.flatMap { $0 }
                let filteredItems = items.filter { $0.name.lowercased().contains(query.lowercased()) }
                state.disposableItems = !filteredItems.isEmpty ? [LifestyleSection(section: .search, items: filteredItems)] : []

                return .none
            }
        }._printChanges()
    }
}
