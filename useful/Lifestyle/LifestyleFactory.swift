//
//  LifestyleFactory.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-23.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import ComposableArchitecture

struct LifestyleFactory {
    func buildLifestyleFeature() -> LifestyleViewController {
        let service = CalendarService()
        let calendar = CalendarFeature.State(
            selectedWeek: service.currentWeek,
            currentMonth: service.currentMonth
        )

        let state = LifestyleFeature.State(
            loadInfo: .init(.didLoad, .loadNew),
            calendarBar: calendar,
            originalItems: [],
            disposableItems: []
        )

        let store = Store(
            initialState: state,
            reducer: LifestyleFeature()
        )

        let calendarStore: StoreOf<CalendarFeature> = store.scope(state: \.calendarBar, action: { .calendarBar($0) })
        let viewStore: LifestyleViewStore = ViewStore(store.scope(state: LifestyleViewController.ViewState.init, action: LifestyleFeature.Action.init))

        return LifestyleViewController(
            viewStore: viewStore,
            calendarStore: calendarStore
        )
    }
}
