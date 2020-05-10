//
//  Date+Operations.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-05-10.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

extension Date {
    
    var startOfMonth: Date? {
        return Calendar.gregorian.date(from: [.year, .month], with: self)
    }
    
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: [.yearForWeekOfYear, .weekOfYear], with: self)
    }
    
    var endOfWeek: Date? {
        guard let sunday = startOfWeek else { return nil }
        return Calendar.gregorian.date(byAdding: .day, value: 6, to: sunday)
    }
}
