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

import EventKit

extension EKEventStore {

    private func earliestEventStartDate(after startDate: Date, before endDate: Date, calendars: [EKCalendar]) -> Date? {
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

    private func earliestEventStartDate(calendars: [CalendarInstance]) -> Date? {
        let calendars = self.calendars(calendars: calendars)
        guard !calendars.isEmpty else {
            return nil
        }

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

    private func earliestEventStartDate(calendars: [EKCalendar]) -> Date? {

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

    private func calendars(calendars: [CalendarInstance]) -> [EKCalendar] {
        let calendarIdentifiers = calendars.map { $0.calendarIdentifier }
        return calendarIdentifiers.compactMap { calendarIdentifier in
            return calendar(withIdentifier: calendarIdentifier)
        }
    }

}

extension EKEventStore: CalendarStore {

    func calendars() -> [CalendarInstance] {
        print("Fetching calendars...")
        return calendars(for: .event)
            .map { CalendarInstance($0) }
    }

    func activeYears(for calendars: [CalendarInstance]) -> [Int] {
        print("Fetching years...")
        let contributingCalendars = calendars.filter { $0.type != .birthday }
        let earliestDate = earliestEventStartDate(calendars: contributingCalendars) ?? .now
        let years = Array((earliestDate.year...Date.now.year).reversed())
        return years
    }

    func events(dateInterval: DateInterval, calendars: [CalendarInstance]) -> [CalendarEvent] {
        let calendars = self.calendars(calendars: calendars)
        guard !calendars.isEmpty else {
            return []
        }
        let predicate = predicateForEvents(withStart: dateInterval.start,
                                           end: dateInterval.end,
                                           calendars: calendars)
        return events(matching: predicate)
            .map { CalendarEvent($0) }
    }

}
