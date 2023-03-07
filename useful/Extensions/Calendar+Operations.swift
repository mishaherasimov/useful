//
//  Calendar+Operations.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-30.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

extension Calendar {

    static let gregorian = Calendar(identifier: .gregorian)

    func monthDays(from date: Date) -> Int? {
        return range(of: .day, in: .month, for: date)?.count
    }

    func date(from components: Set<Component>, with date: Date) -> Date? {
        return self.date(from: dateComponents(components, from: date))
    }
}
