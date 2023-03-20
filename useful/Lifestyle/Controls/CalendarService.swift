//
//  CalendarService.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-20.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import ComposableArchitecture
import Foundation

enum CalendarServiceKey: DependencyKey {
    static let liveValue = CalendarService()
}

extension DependencyValues {
    var calendarService: CalendarService {
        get { self[CalendarServiceKey.self] }
        set { self[CalendarServiceKey.self] = newValue }
    }
}

struct CalendarService {
    func calculateCalendar() -> (days: [Int], currentMonth: Range<Int>)? {
        let calendar = Calendar.gregorian
        let currentDate = Date()

        guard let firstDate = currentDate.startOfMonth else { return nil }

        // Get the short name of the first day of the month. e.g. "Mon"
        let weekDay = firstDate.formatted(as: .custom(style: .day, timeZone: .current))

        // Calculate number of days in current month an the previous one;
        // Find week day for the 1st day of current month
        guard
            let currentMonthDaysCount = calendar.monthDays(from: firstDate),
            let weekDayIndex = calendar.shortWeekdaySymbols.firstIndex(of: weekDay),
            let previousMonth = firstDate.previousMonth,
            let previousMonthDaysCount = calendar.monthDays(from: previousMonth) else { return nil }

        // Offset in days for the 1st day of the month e.g. "Mon", "Tue", "Wed" -> "29", "30", "1"
        let weekDayOffset = calendar.shortWeekdaySymbols.prefix(upTo: Int(weekDayIndex)).indices.last ?? 0
        // Indexes for current month
        let currentMonthDays = Array(1...currentMonthDaysCount)

        // If 1th day is the first day of the week day
        if weekDayOffset == 0 {

            let remainingDays = Array(1...CalendarWeek.daysInAWeek - currentMonthDaysCount)
            return (currentMonthDays + remainingDays, 0..<currentMonthDaysCount)
        } else {

            let previousMonthDays = Array((previousMonthDaysCount - weekDayOffset)...previousMonthDaysCount)
            let joinedDaysTotal = previousMonthDays.count + currentMonthDays.count
            let remainingDays = joinedDaysTotal < CalendarWeek.daysInAWeek ? Array(1...(CalendarWeek.daysInAWeek - joinedDaysTotal)) : []
            let offset = weekDayOffset + 1
            return (previousMonthDays + currentMonthDays + remainingDays, offset..<currentMonthDaysCount + offset)
        }
    }
}
