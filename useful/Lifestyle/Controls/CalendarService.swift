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

enum CalendarWeek: Int, CaseIterable {
    case week1, week2, week3, week4, week5, week6
}

struct DayItem: Equatable, Hashable, Identifiable {
    let id: UUID = .init()
    let day: Int
}

struct CurrentMonth: Equatable {

    /// Digits that represent six weeks of the month
    ///
    /// `[27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9]`
    let dayDigits: [DayItem]

    /// Day digits of the six weeks of the month.
    ///
    /// `[[27, 28, 29, 30, 31, 1, 2],  [3, 4, 5, 6, 7, 8, 9]]`
    let dayDigitWeeks: [[DayItem]]

    /// Range of indexes that represent day digits of the current month
    let digitsRange: Range<Int>
}

final class CalendarService {
    private let today: Date = Date()
    private let calendar: Calendar = Calendar(identifier: .gregorian)
    
    lazy var currentMonth: CurrentMonth = currentMonthData()
    lazy var currentWeek: CalendarWeek = findCurrentWeek()

    private func findCurrentWeek() -> CalendarWeek {
        let itemSubrange = Array(currentMonth.dayDigits[currentMonth.digitsRange])

        guard let day = calendar.dateComponents([.day], from: today).day,
              let index = itemSubrange.firstIndex(where: { $0.day == day }),
              let week = CalendarWeek(rawValue: Int(floor(Double((index + currentMonth.digitsRange.lowerBound) / 7)))) else {
            return .week1
        }

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

            let dayDigits = Array(1...currentMonthDaysCount) + Array(1...remainingDaysOfTheNextMonth)
            let days = dayDigits.map(DayItem.init(day:))

            return CurrentMonth(
                dayDigits: days,
                dayDigitWeeks: days.chunked(into: totalDayInWeek),
                digitsRange: 0..<currentMonthDaysCount
            )
        } else {
            let remainingDaysOfThePreviousMonth = Array((previousMonthDaysCount - weekDayOffset)...previousMonthDaysCount)
            let currentMonthDays = Array(1...currentMonthDaysCount)

            let remainingDaysOfTheNextMonthCount = totalDaysInSixWeeks - min(remainingDaysOfThePreviousMonth.count + currentMonthDays.count, totalDaysInSixWeeks)
            let remainingDaysOfTheNextMonth = Array(1...remainingDaysOfTheNextMonthCount)

            let offset = weekDayOffset + 1
            let dayDigits = remainingDaysOfThePreviousMonth + currentMonthDays + remainingDaysOfTheNextMonth
            let days = dayDigits.map(DayItem.init(day:))

            return CurrentMonth(
                dayDigits: days,
                dayDigitWeeks: days.chunked(into: totalDayInWeek),
                digitsRange: offset..<currentMonthDaysCount + offset
            )
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
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
