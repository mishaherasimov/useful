//
//  DateFormatPreset.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Foundation

enum DateFormatPreset: Hashable {

    enum CustomStyle: String, Equatable, Hashable {

        case monthYear = "MMMM yyyy"
        case day = "EE"
        case weekDay = "MMM dd"
    }

    case system(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone?)
    case custom(style: CustomStyle, timeZone: TimeZone?)
}

extension Date {
    func formatted(as format: DateFormatPreset) -> String {
        let formatter = DateFormatter.cached(with: format)
        return formatter.string(from: self)
    }
}
