//
//  DateFormatter+Caching.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

private var cachedFormatters = [DateFormatPreset: DateFormatter]()

extension DateFormatter {

    static func cached(with preset: DateFormatPreset) -> DateFormatter {
        if let cachedFormatter = cachedFormatters[preset] {
            return cachedFormatter
        }

        let formatter = DateFormatter()

        switch preset {
        case .system(let dateStyle, let timeStyle, let timeZone):

            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            formatter.timeZone = timeZone
        case .custom(let format, let timeZone):

            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = timeZone
            formatter.dateFormat = format.rawValue
        }

        cachedFormatters[preset] = formatter
        return formatter
    }
}
