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

enum CalendarWeek: Int, CaseIterable {
    case week1, week2, week3, week4, week5, week6

    static var daysInAWeek: Int {
        7
    }
}

struct CalendarFeature: ReducerProtocol {
    enum Action {

    }

    struct State {
        var selectedWeek: CalendarWeek = .week1
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
