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

extension Calendar {

    func events(calendar: CalendarInstance,
                weeks: [Int],
                days: [Weekday],
                year: Int,
                hour: Int,
                duration: DateComponents,
                title: String) -> [CalendarEvent] {
        let events = weeks
            .map { weeklyOrdinal -> [CalendarEvent] in
                return days.map { weekday -> CalendarEvent in
                    let components = DateComponents(year: year,
                                                    hour: hour,
                                                    weekday: weekday.rawValue,
                                                    weekdayOrdinal: weeklyOrdinal)
                    let startDate = date(from: components)!
                    let endDate = date(byAdding: duration, to: startDate)!
                    return CalendarEvent(calendar: calendar,
                                         startDate: startDate,
                                         endDate: endDate,
                                         title: title)
                }
            }
            .reduce([], +)
        return events
    }

}

class DemoStore: CalendarStore {

    private let currentYear: Int
    private let demoCalendars: [CalendarInstance]
    private let demoEvents: [CalendarEvent]

    init() {

        let homeCalendar = CalendarInstance(title: "Home", color: .blue)
        let workCalendar = CalendarInstance(title: "Work", color: .red)
        let whereCalendar = CalendarInstance(title: "Where", color: .orange)

        let currentYear = Date.now.year

        var calendar = Calendar.gregorian
        calendar.timeZone = Calendar.current.timeZone
        calendar.firstWeekday = 1

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "cccc, d M yyyy, HH:mm"

        let weeks = 10

        let coffeeWithTom = calendar.events(calendar: homeCalendar,
                                            weeks: Array(1..<weeks),
                                            days: [Weekday.friday],
                                            year: currentYear,
                                            hour: 10,
                                            duration: DateComponents(hour: 1),
                                            title: "Coffee with Tom")

        let faceTimeWithLukas = calendar.events(calendar: homeCalendar,
                                                weeks: Array(stride(from: 1, to: weeks, by: 2)),
                                                days: [Weekday.friday],
                                                year: currentYear,
                                                hour: 14,
                                                duration: DateComponents(hour: 1),
                                                title: "FaceTime with Lukas")

        // TODO: Weekday option set.
        let standup = calendar.events(calendar: workCalendar,
                                      weeks: Array(1..<weeks),
                                      days: [.monday, .tuesday, .wednesday, .thursday, .friday],
                                      year: currentYear,
                                      hour: 9,
                                      duration: DateComponents(minute: 15),
                                      title: "Standup")

        self.currentYear = currentYear

        self.demoCalendars = [
            homeCalendar,
            workCalendar,
            whereCalendar,
        ]
        self.demoEvents = coffeeWithTom + faceTimeWithLukas + standup
    }

    func calendars() -> [CalendarInstance] {
        return demoCalendars
    }

    func activeYears(for calendars: [CalendarInstance]) -> [Int] {
        return [currentYear]
    }

    func events(dateInterval: DateInterval, calendars: [CalendarInstance]) -> [CalendarEvent] {
        return demoEvents
            .filter { event in
                return calendars.contains(event.calendar)
            }
            .filter { event in
                event.dateInterval.intersects(dateInterval)
            }
    }

}
