//
//  Manager.swift
//  Where
//
//  Created by Jason Barrie Morley on 13/03/2021.
//

import EventKit
import Foundation
import SwiftUI

class Manager: ObservableObject {

    fileprivate let store = EKEventStore()

    @Published var calendars: [EKCalendar] = []

    init() {
        store.requestAccess(to: .event) { granted, error in
            // TODO: Handle the error.
            DispatchQueue.main.async {
                print("granted = \(granted), error = \(String(describing: error))")
                self.update()
            }
        }
    }

    func update() {
        dispatchPrecondition(condition: .onQueue(.main))
        calendars = store.calendars(for: .event)
    }

    func calendar(identifier: String) -> EKCalendar? {
        store.calendar(withIdentifier: identifier)
    }

    func events(dateInterval: DateInterval, calendars: [EKCalendar]?) -> [EKEvent] {
        let predicate = store.predicateForEvents(withStart: dateInterval.start,
                                                 end: dateInterval.end,
                                                 calendars: calendars)
        return store.events(matching: predicate)
    }

    func events(dateInterval: DateInterval, granularity: DateComponents, calendars: [EKCalendar]?) throws -> [EKEvent] {
        let calendar = Calendar.current  // TODO: Gregorian calendar
        var results: [EKEvent] = []
        calendar.enumerate(dateInterval: dateInterval, components: granularity) { dateInterval in
            results = results + events(dateInterval: dateInterval, calendars: calendars)
        }
        return results
    }

    func summaries(dateInterval: DateInterval, granularity: DateComponents, calendars: [EKCalendar]?) throws -> [Summary<EKEvent>] {
        let events: [EKEvent] = try self.events(dateInterval: dateInterval,
                                                granularity: granularity,
                                                calendars: calendars)
        let group = Dictionary(grouping: events) { $0.title ?? "Unknown" }
        var results: [Summary<EKEvent>] = []
        for (_, events) in group {
            results.append(Summary(dateInterval: dateInterval, items: events))
        }
        return results
    }

    // TODO: Move this onto the calendar
    func summaries(dateInterval: DateInterval, calendars: [EKCalendar]) throws -> [Summary<Summary<EKEvent>>] {
        let calendar = Calendar.current
        var results: [Summary<Summary<EKEvent>>] = []
        calendar.enumerate(dateInterval: dateInterval, components: DateComponents(month: 1)) { dateInterval in
            let summaries = try! self.summaries(dateInterval: dateInterval,
                                                granularity: DateComponents(month: 1),
                                                calendars: calendars)
            results.append(Summary(dateInterval: dateInterval, items: summaries))
        }
        return results
    }

    func summary(year: Int, calendars: [EKCalendar]) throws -> [Summary<Summary<EKEvent>>] {
        let calendar = Calendar.current
        guard let start = calendar.date(from: DateComponents(year: year, month: 1)) else {
            throw CalendarError.invalidDate
        }
        let dateInterval = try calendar.dateInterval(start: start, duration: DateComponents(year: 1))
        return try summaries(dateInterval: dateInterval, calendars: calendars)

    }

}
