//
//  Calendar.swift
//  Where
//
//  Created by Jason Barrie Morley on 13/03/2021.
//

import EventKit
import Foundation

extension Calendar {

    func dateInterval(start: Date, duration: DateComponents) throws -> DateInterval {
        guard let end = date(byAdding: duration, to: start) else {
            throw CalendarError.invalidDate
        }
        return DateInterval(start: start, end: end)
    }

    func enumerate(dateInterval: DateInterval, components: DateComponents, block: (DateInterval) -> Void) {
        var date = dateInterval.start
        while date < dateInterval.end {
            guard let nextDate = self.date(byAdding: components, to: date) else {
                // TODO: This is an error?
                return
            }
            block(DateInterval(start: date, end: nextDate))
            date = nextDate
        }
    }

}
