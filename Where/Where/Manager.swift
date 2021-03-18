// Copyright (c) 2021 Jason Barrie Morley
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

    func summaries(calendar: Calendar, dateInterval: DateInterval, calendars: [EKCalendar]) throws -> [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] {
        var results: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []
        calendar.enumerate(dateInterval: dateInterval, components: DateComponents(month: 1)) { dateInterval in
            let summaries = try! store.summaries(calendar: calendar,
                                                 dateInterval: dateInterval,
                                                 granularity: DateComponents(month: 1),
                                                 calendars: calendars)
            results.append(Summary(dateInterval: dateInterval, context: calendars, items: summaries))
        }
        return results
    }

    func summary(calendar: Calendar, year: Int, calendars: [EKCalendar]) throws -> [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] {
        guard let start = calendar.date(from: DateComponents(year: year, month: 1)) else {
            throw CalendarError.invalidDate
        }
        let dateInterval = try calendar.dateInterval(start: start, duration: DateComponents(year: 1))
        return try summaries(calendar: calendar, dateInterval: dateInterval, calendars: calendars)
    }

}
