//
//  CalendarService.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-20.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import Foundation
import ComposableArchitecture

enum CalendarKey: DependencyKey {
    static let liveValue = Calendar(identifier: .gregorian)
}

extension DependencyValues {
    var calendar: Calendar {
        get { self[CalendarKey.self] }
        set { self[CalendarKey.self] = newValue }
    }
}

enum CalendarServiceKey: DependencyKey {
    static let liveValue = CalendarService()
}

extension DependencyValues {
    var calendarService: CalendarService {
        get { self[CalendarServiceKey.self] }
        set { self[CalendarServiceKey.self] = newValue }
    }
}

enum CalendarWeek: Int, CaseIterable {
    case week1, week2, week3, week4, week5, week6
}

struct DayItem: Equatable, Hashable, Identifiable {
    let id: UUID
    let day: Int
    let isCurrent: Bool

    init(id: UUID = .init(), day: Int, isCurrent: Bool = false) {
        self.id = id
        self.day = day
        self.isCurrent = isCurrent
    }

    init(date: Date) {
        @Dependency(\.calendar) var calendar: Calendar

        let components = calendar.dateComponents([.day], from: date)
        guard let day = components.day else {
            fatalError("Cannot retrieve day information from the date \(date)")
        }

        self.init(day: day)
    }
}

/// Day digits of the six weeks of the month.
///
/// `[[27, 28, 29, 30, 31, 1, 2],  [3, 4, 5, 6, 7, 8, 9]]`
typealias CurrentMonth = [[DayItem]]

final class CalendarService {
    private let today: Date = Date()
    @Dependency(\.calendar) private var calendar: Calendar
    
    lazy var currentMonth: CurrentMonth = currentMonthData()
    lazy var currentWeek: CalendarWeek = findCurrentWeek()

    func weekSpan(using day: DayItem) -> (beginning: Date, end: Date) {
        guard let current = calendar.date(bySetting: .day, value: day.day, of: today) else {
            fatalError("Cannot calculate week span")
        }

        let beginning = calendar.newDate(from: [.yearForWeekOfYear, .weekOfYear], with: current)
        guard let end = calendar.date(byAdding: .day, value: 6, to: beginning) else {
            fatalError("Cannot calculate week span")
        }

        return (beginning, end)
    }

    private func findCurrentWeek() -> CalendarWeek {
        guard let dayNum = calendar.dateComponents([.day], from: today).day,
              let weekIndex = currentMonth.firstIndex(where: { items in items.contains { $0.isCurrent && $0.day == dayNum }}),
              let week = CalendarWeek(rawValue: Int(weekIndex)) else { return .week1 }

        return week
    }

    private func currentMonthData() -> CurrentMonth {
        let totalDayInWeek = 7
        let totalDaysInSixWeeks = CalendarWeek.allCases.count * totalDayInWeek

        let firstMonthDay = calendar.firstDayOfMonth(using: today)

        // Calculate number of days in current month an the previous one;
        let currentMonthDaysCount = calendar.daysInMonth(using: firstMonthDay)
        let previousMonthDaysCount = calendar.daysInMonth(using: calendar.previousMonthDay(using: firstMonthDay))

        // Get the short name of the first day of the month. e.g. "Mon"
        let weekDay = firstMonthDay.formatted(as: .custom(style: .day, timeZone: .current))

        // Offset in days for the 1st day of the month e.g. "Mon", "Tue", "Wed" -> "29", "30", "1"
        let weekDayOffset = calendar.shortWeekdaySymbols.firstIndex(of: weekDay).map { Int($0) } ?? 0

        // Today's date is the first day of the month
        if weekDayOffset == .zero {
            let remainingDaysOfTheNextMonth = totalDaysInSixWeeks - currentMonthDaysCount

            let currentMonth = Array(1...currentMonthDaysCount).map { DayItem(day: $0, isCurrent: true) }
            let nextMonth = Array(1...remainingDaysOfTheNextMonth).map { DayItem(day: $0) }

            return (currentMonth + nextMonth).chunked(into: totalDayInWeek)
        } else {
            let currentMonth = Array(1...currentMonthDaysCount).map { DayItem(day: $0, isCurrent: true) }
            let previousMonth = (1...previousMonthDaysCount)
                .suffix(weekDayOffset)
                .map { DayItem(day: $0) }

            let remainingDaysOfTheNextMonthCount = totalDaysInSixWeeks - min(previousMonth.count + currentMonth.count, totalDaysInSixWeeks)
            let nextMonth = Array(1...remainingDaysOfTheNextMonthCount).map { DayItem(day: $0) }

            return (previousMonth + currentMonth + nextMonth).chunked(into: totalDayInWeek)
        }
    }
}

private extension Calendar {
    func previousMonthDay(using date: Date) -> Date {
        guard let newDate = self.date(byAdding: .month, value: -1, to: date) else {
            fatalError("Can't get a date of the previous month")
        }

        return newDate
    }

    func firstDayOfMonth(using date: Date) -> Date {
        newDate(from: [.year, .month], with: date)
    }

    /// Calculates number of days in a month
    /// - Parameter using: Date to use to determine current month
    /// - Returns: Day count in a particular month
    func daysInMonth(using date: Date) -> Int {
        guard let count = range(of: .day, in: .month, for: date)?.count else {
            fatalError("Can't calculate days in a month")
        }

        return count
    }

    func newDate(from components: Set<Component>, with date: Date) -> Date {
        guard let newDate = self.date(from: dateComponents(components, from: date)) else {
            fatalError("Can't calculate new date using components \(components)")
        }

        return newDate
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
