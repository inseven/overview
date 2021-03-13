//
//  WhereApp.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

extension EKCalendar: Identifiable {
    public var id: String { calendarIdentifier }
}

extension EKCalendarItem: Identifiable {
    public var id: String { calendarItemIdentifier }
}

enum CalendarError: Error {
    case failure
    case unknownCalendar
    case invalidDate
}

struct Summary<Item>: Identifiable {
    var id = UUID()
    var dateInterval: DateInterval
    var items: [Item]
}

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

    func summaries(dateInterval: DateInterval, granularity: DateComponents, calendars: [EKCalendar]?) throws -> [Summary<EKCalendarItem>] {
        let events: [EKCalendarItem] = try self.events(dateInterval: dateInterval,
                                                       granularity: granularity,
                                                       calendars: calendars)
        let group = Dictionary(grouping: events) { $0.title ?? "Unknown" }
        var results: [Summary<EKCalendarItem>] = []
        for (_, events) in group {
            results.append(Summary(dateInterval: dateInterval, items: events))
        }
        return results
    }

    // TODO: Move this onto the calendar
    func summaries(dateInterval: DateInterval, calendarIdentifier: String) throws -> [Summary<Summary<EKCalendarItem>>] {
        guard let eventCalendar = calendar(identifier: calendarIdentifier) else {
            throw CalendarError.unknownCalendar
        }
        let calendar = Calendar.current
        var results: [Summary<Summary<EKCalendarItem>>] = []
        calendar.enumerate(dateInterval: dateInterval, components: DateComponents(month: 1)) { dateInterval in
            let summaries = try! self.summaries(dateInterval: dateInterval,
                                                granularity: DateComponents(day: 1),
                                                calendars: [eventCalendar])
            results.append(Summary(dateInterval: dateInterval, items: summaries))
        }
        return results
    }

    func summary(year: Int, calendarIdentifier: String) throws -> [Summary<Summary<EKCalendarItem>>] {
        let calendar = Calendar.current
        guard let start = calendar.date(from: DateComponents(year: year, month: 1)) else {
            throw CalendarError.invalidDate
        }
        let dateInterval = try calendar.dateInterval(start: start, duration: DateComponents(year: 1))
        return try summaries(dateInterval: dateInterval, calendarIdentifier: calendarIdentifier)

    }

}

@main
struct WhereApp: App {

    @ObservedObject var manager = Manager()

    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView(manager: manager)
            }
        }
        .commands {
            SidebarCommands()
        }
    }
}
