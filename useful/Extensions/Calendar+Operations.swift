//
//  Calendar+Operations.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-30.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

extension Calendar {
    
    func monthDays(from date: Date) -> Int? {
        return range(of: .day, in: .month, for: date)?.count
    }
     
    func firstMonthDay(based currentDate: Date) -> Date? {
        let currentDateComponents = dateComponents([.year, .month], from: currentDate)
        return date(from: currentDateComponents)
    }
    
    func previousMonth(from currentDate: Date) -> Date? {
        return date(byAdding: DateComponents(month: -1), to: currentDate)
    }
}
