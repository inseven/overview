// Copyright (c) 2021-2025 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

protocol CalendarStore {

    func calendars() -> [CalendarInstance]
    func activeYears(for calendars: [CalendarInstance]) -> [Int]
    func events(dateInterval: DateInterval, calendars: [CalendarInstance]) -> [CalendarEvent]

}

extension CalendarStore {

    private func events(calendar: Calendar,
                        dateInterval: DateInterval,
                        granularity: DateComponents,
                        calendars: [CalendarInstance]) throws -> [CalendarEvent] {
        var results: [CalendarEvent] = []
        calendar.enumerate(dateInterval: dateInterval, components: granularity) { dateInterval in
            results = results + events(dateInterval: dateInterval, calendars: calendars)
        }
        return results
    }

    private func summaries(calendar: Calendar,
                           dateInterval: DateInterval,
                           granularity: DateComponents,
                           calendars: [CalendarInstance]) throws -> [SimilarEvents] {
        let events: [CalendarEvent] = try self.events(calendar: calendar,
                                                      dateInterval: dateInterval,
                                                      granularity: granularity,
                                                      calendars: calendars)
        let group = Dictionary(grouping: events) { CalendarItem(calendar: $0.calendar , title: $0.title) }
        var results: [SimilarEvents] = []
        for (context, events) in group {
            results.append(Summary(dateInterval: dateInterval, context: context, items: events))
        }
        return results
    }

    private func summaries(calendar: Calendar,
                           dateInterval: DateInterval,
                           calendars: [CalendarInstance],
                           granularity: DateComponents) throws -> [PeriodSummary] {
        var results: [PeriodSummary] = []
        calendar.enumerate(dateInterval: dateInterval, components: granularity) { dateInterval in
            let summaries = try! self.summaries(calendar: calendar,
                                                dateInterval: dateInterval,
                                                granularity: granularity,
                                                calendars: calendars)
            results.append(Summary(dateInterval: dateInterval, context: calendars, items: summaries))
        }
        return results
    }

    func startDate(calendar: Calendar, year: Int, granularity: Granularity) throws -> Date {

        var components = DateComponents()
        switch granularity {
        case .weekly:
            components.yearForWeekOfYear = year
            components.weekOfYear = 1
            components.weekday = calendar.firstWeekday
        case .monthly:
            components.year = year
            components.month = 1
        }

        guard let startDate = calendar.date(from: components) else {
            throw CalendarError.invalidDate
        }

        return startDate
    }

    func summary(calendar: Calendar,
                 year: Int,
                 calendars: [CalendarInstance],
                 granularity: Granularity) throws -> [PeriodSummary] {
        let startDate = try startDate(calendar: calendar, year: year, granularity: granularity)
        let dateInterval = try calendar.dateInterval(start: startDate, duration: DateComponents(year: 1))
        let summaries = try summaries(calendar: calendar,
                                      dateInterval: dateInterval,
                                      calendars: calendars,
                                      granularity: granularity.dateComponents)
        return summaries
    }

}
