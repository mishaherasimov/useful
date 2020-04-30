//
//  DateFormatPreset.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

enum DateFormatPreset {

    enum CustomStyle: String, Equatable, Hashable {

        case monthYear = "MMMM yyyy"
        case day = "EE"
    }

    case system(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone?)
    case custom(style: CustomStyle, timeZone: TimeZone?)
}

extension DateFormatPreset: Hashable {

    static func == (lhs: DateFormatPreset, rhs: DateFormatPreset) -> Bool {

        switch (lhs, rhs) {
        case (let .system(lhsDateStyle, lhsTimeStyle, lhsTimeZone), let .system(rhsDateStyle, rhsTimeStyle, rhsTimeZone)):

            return lhsDateStyle == rhsDateStyle && lhsTimeStyle == rhsTimeStyle && lhsTimeZone == rhsTimeZone
        case let (.custom(lhsFormat, lhsTimeZone), .custom(rhsFormat, rhsTimeZone)):

            return lhsFormat == rhsFormat && lhsTimeZone == rhsTimeZone
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {

        switch self {
        case let .system(dateStyle, timeStyle, timeZone):

            hasher.combine(dateStyle)
            hasher.combine(timeStyle)
            hasher.combine(timeZone)
        case let .custom(format, timeZone):

            hasher.combine(timeZone)
            hasher.combine(format)
        }
    }
}

extension Date {

    func formatted(as format: DateFormatPreset) -> String {

        let formatter = DateFormatter.cached(with: format)
        return formatter.string(from: self)
    }
}
