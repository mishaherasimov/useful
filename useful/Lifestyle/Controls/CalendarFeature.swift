//
//  CalendarFeature.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-19.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import Combine
import ComposableArchitecture
import Foundation

struct CalendarFeature: ReducerProtocol {
    enum Action {
        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case didSelect(Timeframe)
    }

    struct State: Equatable {
        var selectedWeek: CalendarWeek = .week1
        let currentMonth: CurrentMonth
        let totalWeeks: Int = CalendarWeek.allCases.count
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate(.didSelect(let timeframe)):
                state.selectedWeek = timeframe.week
                return .none
            }
        }
    }
}
