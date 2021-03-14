//
//  EKEvent.swift
//  Where
//
//  Created by Jason Barrie Morley on 13/03/2021.
//

import EventKit

extension EKEvent {

    func duration(calendar: Calendar, bounds: DateInterval) -> DateComponents {
        let start = max(bounds.start, startDate)
        let end = min(bounds.end, endDate)
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}
