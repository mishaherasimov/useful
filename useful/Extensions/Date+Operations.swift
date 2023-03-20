//
//  Date+Operations.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-10.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

extension Date {
    var startOfWeek: Date? {
        Calendar(identifier: .gregorian).newDate(from: [.yearForWeekOfYear, .weekOfYear], with: self)
    }

    var endOfWeek: Date? {
        guard let sunday = startOfWeek else { return nil }
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: 6, to: sunday)
    }
}

extension Calendar {
    func newDate(from components: Set<Component>, with date: Date) -> Date {
        guard let newDate = self.date(from: dateComponents(components, from: date)) else {
            fatalError("Can't calculate new date using components \(components)")
        }

        return newDate
    }
}
