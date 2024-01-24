// Copyright (c) 2021-2024 Jason Morley
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

class DemoStore: CalendarStore {

    private let currentYear: Int
    private let demoData: [CalendarInstance: [CalendarEvent]]

    init() {
        var demoData = [CalendarInstance: [CalendarEvent]]()

        let homeCalendar = CalendarInstance(title: "Home", color: .blue)
        let workCalendar = CalendarInstance(title: "Work", color: .red)
        let whereCalendar = CalendarInstance(title: "Where", color: .orange)

        let currentYear = Date.now.year

        var calendar = Calendar.gregorian
        calendar.timeZone = Calendar.current.timeZone
        calendar.firstWeekday = 1

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "cccc, d M yyyy, HH:mm"

        let coffeeWithTom = Array(1..<6)
            .map { weeklyOrdinal in
                let components = DateComponents(year: currentYear, hour: 10, weekday: Weekday.friday, weekdayOrdinal: weeklyOrdinal)
                let startDate = calendar.date(from: components)!
                let endDate = calendar.date(byAdding: DateComponents(hour: 1), to: startDate)!
                return CalendarEvent(calendar: homeCalendar, startDate: startDate, endDate: endDate, title: "Coffee with Tom")
            }

        let faceTimeWithLukas = Array(stride(from: 1, to: 6, by: 2))
            .map { weeklyOrdinal in
                let components = DateComponents(year: currentYear, hour: 14, weekday: Weekday.friday, weekdayOrdinal: weeklyOrdinal)
                let startDate = calendar.date(from: components)!
                let endDate = calendar.date(byAdding: DateComponents(hour: 1), to: startDate)!
                return CalendarEvent(calendar: workCalendar, startDate: startDate, endDate: endDate, title: "FaceTime with Lukas")
            }

        demoData[homeCalendar] = coffeeWithTom
        demoData[workCalendar] = faceTimeWithLukas
        demoData[whereCalendar] = []

        self.currentYear = currentYear
        self.demoData = demoData
    }

    func calendars() -> [CalendarInstance] {
        return Array(demoData.keys)
    }

    func activeYears(for calendars: [CalendarInstance]) -> [Int] {
        return [currentYear]
    }

    func events(dateInterval: DateInterval, calendars: [CalendarInstance]) -> [CalendarEvent] {
        return demoData
            .filter { calendar, events in
                return calendars.contains(calendar)
            }
            .map { _, events in
                return events
            }
            .reduce([], +)
            .filter { event in
                event.dateInterval.intersects(dateInterval)
            }
    }

}
