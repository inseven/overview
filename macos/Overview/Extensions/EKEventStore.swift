// Copyright (c) 2021-2023 Jason Barrie Morley
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

import EventKit

extension EKEventStore {

    func events(dateInterval: DateInterval, calendars: [EKCalendar]?) -> [EKEvent] {
        let predicate = predicateForEvents(withStart: dateInterval.start,
                                                 end: dateInterval.end,
                                                 calendars: calendars)
        return events(matching: predicate)
    }

    func events(calendar: Calendar,
                dateInterval: DateInterval,
                granularity: DateComponents,
                calendars: [EKCalendar]?) throws -> [EKEvent] {
        var results: [EKEvent] = []
        calendar.enumerate(dateInterval: dateInterval, components: granularity) { dateInterval in
            results = results + events(dateInterval: dateInterval, calendars: calendars)
        }
        return results
    }

    func summaries(calendar: Calendar,
                   dateInterval: DateInterval,
                   granularity: DateComponents,
                   calendars: [EKCalendar]?) throws -> [Summary<CalendarItem, EKEvent>] {
        let events: [EKEvent] = try self.events(calendar: calendar,
                                                dateInterval: dateInterval,
                                                granularity: granularity,
                                                calendars: calendars)
        let group = Dictionary(grouping: events) { CalendarItem(calendar: $0.calendar , title: $0.title ?? "") }
        var results: [Summary<CalendarItem, EKEvent>] = []
        for (context, events) in group {
            results.append(Summary(dateInterval: dateInterval, context: context, items: events))
        }
        return results
    }

    func summaries(calendar: Calendar,
                   dateInterval: DateInterval,
                   calendars: [EKCalendar]) throws -> [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] {
        var results: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []
        calendar.enumerate(dateInterval: dateInterval, components: DateComponents(month: 1)) { dateInterval in
            let summaries = try! self.summaries(calendar: calendar,
                                                dateInterval: dateInterval,
                                                granularity: DateComponents(month: 1),
                                                calendars: calendars)
            results.append(Summary(dateInterval: dateInterval, context: calendars, items: summaries))
        }
        return results
    }

    func summary(calendar: Calendar,
                 year: Int,
                 calendars: [EKCalendar]) throws -> [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] {
        guard let start = calendar.date(from: DateComponents(year: year, month: 1)) else {
            throw CalendarError.invalidDate
        }
        let dateInterval = try calendar.dateInterval(start: start, duration: DateComponents(year: 1))
        return try summaries(calendar: calendar, dateInterval: dateInterval, calendars: calendars)
    }

    func earliestEventStartDate(after startDate: Date, before endDate: Date, calendars: [EKCalendar]) -> Date? {
        var result: Date? = nil
        enumerateEvents(matching: predicateForEvents(withStart: startDate,
                                                     end: endDate,
                                                     calendars: calendars)) { event, stop in
            guard event.startDate != nil else {
                return
            }
            result = event.startDate
            stop.pointee = true
        }
        return result
    }

    func earliestEventStartDate(calendars: [EKCalendar]) -> Date? {
        // Search backwards for the earliest calendar entry in 4 year intervals (documented EventKit restriction).
        var result: Date? = nil
        let iterator = DateRangeIterator(date: .now, increment: DateComponents(year: -4))
        for (startDate, endDate) in iterator {
            guard let date = earliestEventStartDate(after: startDate, before: endDate, calendars: calendars) else {
                return result
            }
            result = date
        }
        return result
    }

}
