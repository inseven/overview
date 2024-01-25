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
                year: Int,
                weeks: [Int],
                days: [Weekday],
                start: DateComponents,
                duration: DateComponents,
                title: String) -> [CalendarEvent] {
        let events = weeks
            .map { weekdayOrdinal -> [CalendarEvent] in
                return days.map { weekday -> CalendarEvent in
                    var components = start
                    components.year = year
                    components.weekday = weekday.rawValue
                    components.weekdayOrdinal = weekdayOrdinal
                    let startDate = date(from: components)!
                    let endDate = date(byAdding: duration, to: startDate)!
                    return CalendarEvent(calendar: calendar, startDate: startDate, endDate: endDate, title: title)
                }
            }
            .reduce([], +)
        return events
    }

    func event(calendar: CalendarInstance,
               start: DateComponents,
               duration: DateComponents,
               title: String) -> CalendarEvent {
        let startDate = date(from: start)!
        let endDate = date(byAdding: duration, to: startDate)!
        return CalendarEvent(calendar: calendar, startDate: startDate, endDate: endDate, title: title)
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

        var calendar = Calendar.gregorian
        calendar.timeZone = Calendar.current.timeZone
        calendar.firstWeekday = 1

        let weekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekend: [Weekday] = [.saturday, .sunday]

        var events = [CalendarEvent]()

        // Home

        // Repeating Events

        // Morning Yoga Class (Monday, Wednesday, Friday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.monday, .wednesday, .friday],
                                                  start: DateComponents(hour: 7),
                                                  duration: DateComponents(hour: 1),
                                                  title: "Morning Yoga Class"))

        // Photography Course (Tuesday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.tuesday],
                                                  start: DateComponents(hour: 18),
                                                  duration: DateComponents(hour: 2),
                                                  title: "Photography Course 📷"))

        // Reading Hour (Daily)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: weekdays + weekend,
                                                  start: DateComponents(hour: 20),
                                                  duration: DateComponents(hour: 1),
                                                  title: "Reading Hour 📖"))

        // Grocery Shopping (Saturday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.saturday],
                                                  start: DateComponents(hour: 10),
                                                  duration: DateComponents(hour: 1),
                                                  title: "Grocery Shopping"))

        // Family Time (Saturday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.saturday],
                                                  start: DateComponents(hour: 13, minute: 00),
                                                  duration: DateComponents(hour: 3),
                                                  title: "Family Time"))

        // Nature Walk (Sunday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.sunday],
                                                  start: DateComponents(hour: 10, minute: 00),
                                                  duration: DateComponents(hour: 2, minute: 30),
                                                  title: "Nature Walk 🍁"))

        // Movie Night (Sunday)
        events.append(contentsOf: calendar.events(calendar: homeCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: [.sunday],
                                                  start: DateComponents(hour: 18, minute: 00),
                                                  duration: DateComponents(hour: 2),
                                                  title: "Movie Night 🍿"))

        // One-off Events

        // January Events
        events.append(calendar.event(calendar: homeCalendar,
                                     start: DateComponents(year: 2024, month: 1, day: 26, hour: 19, minute: 00),
                                     duration: DateComponents(hour: 3, minute: 0),
                                     title: "Birthday Party"))

        // February Events
        events.append(calendar.event(calendar: homeCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 3, hour: 8, minute: 00),
                                     duration: DateComponents(hour: 2, minute: 0),
                                     title: "Local Charity Run 🏃🏻‍♀️"))
        events.append(calendar.event(calendar: homeCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 9, hour: 11, minute: 00),
                                     duration: DateComponents(hour: 2, minute: 0),
                                     title: "Cooking Class - Italian Cuisine 🇮🇹"))
        events.append(calendar.event(calendar: homeCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 14, hour: 20, minute: 00),
                                     duration: DateComponents(hour: 3, minute: 0),
                                     title: "Valentine's Day Dinner ❤️"))

        // Work

        // Repeating Events

        // Standup (Monday - Friday)
        events.append(contentsOf: calendar.events(calendar: workCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: weekdays,
                                                  start: DateComponents(hour: 9),
                                                  duration: DateComponents(minute: 15),
                                                  title: "Standup"))

        // Team Meeting (Monday - Friday)
        events.append(contentsOf: calendar.events(calendar: workCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: weekdays,
                                                  start: DateComponents(hour: 13),
                                                  duration: DateComponents(hour: 1),
                                                  title: "Team Meeting"))

        // Project Work (Monday - Friday)
        events.append(contentsOf: calendar.events(calendar: workCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: weekdays,
                                                  start: DateComponents(hour: 10, minute: 30),
                                                  duration: DateComponents(hour: 1, minute: 30),
                                                  title: "Project Work"))

        // Report Writing (Monday - Friday)
        events.append(contentsOf: calendar.events(calendar: workCalendar,
                                                  year: 2024,
                                                  weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                                                  days: weekdays,
                                                  start: DateComponents(hour: 16, minute: 00),
                                                  duration: DateComponents(hour: 1),
                                                  title: "Report Writing"))

        // One-off Events

        // January Events
        events.append(calendar.event(calendar: workCalendar,
                                     start: DateComponents(year: 2024, month: 1, day: 8, hour: 12, minute: 30),
                                     duration: DateComponents(hour: 1, minute: 30),
                                     title: "New Year's Team Lunch"))
        events.append(calendar.event(calendar: workCalendar,
                                     start: DateComponents(year: 2024, month: 1, day: 22, hour: 15, minute: 00),
                                     duration: DateComponents(hour: 2, minute: 0),
                                     title: "Web Design Workshop"))

        // February Events
        events.append(calendar.event(calendar: workCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 20, hour: 18, minute: 00),
                                     duration: DateComponents(hour: 2, minute: 0),
                                     title: "Professional Networking Event"))
        events.append(calendar.event(calendar: workCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 28, hour: 14, minute: 00),
                                     duration: DateComponents(hour: 2, minute: 0),
                                     title: "Spacial Computing Tech Talk"))

        // Where

        let generateWhereEvents = { (start: DateComponents, end: DateComponents, place: String) in

            // Get the day start and end offsets from the start of the year to make iterating easier.

            let startDate = calendar.date(from: start)!
            let endDate = calendar.date(from: end)!

            let startDay = calendar.ordinality(of: .day, in: .year, for: startDate)!
            let endDay = calendar.ordinality(of: .day, in: .year, for: endDate)!

            // Iterate over the days generating the event.

            print("\(startDay) -> \(endDay)")
            for i in startDay..<endDay {

                let date = calendar.date(from: DateComponents(year: 2024, day: i))!

                print(date)

                let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)
                let isWeekend = weekend.contains(Weekday(rawValue: dateComponents.weekday!)!)
                let title = "\(place) (\(isWeekend ? "Weekend" : "Work"))"
                events.append(calendar.event(calendar: whereCalendar,
                                             start: dateComponents,
                                             duration: DateComponents(day: 1),
                                             title: title))

            }

        }

        // London (January 1 - February 14)
        generateWhereEvents(DateComponents(year: 2024, month: 1, day: 1),
                            DateComponents(year: 2024, month: 2, day: 15),
                            "London, UK")

        // February Trip to Paris
        events.append(calendar.event(calendar: whereCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 15),
                                     duration: DateComponents(day: 1),
                                     title: "Paris, France (Vacation)"))
        events.append(calendar.event(calendar: whereCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 16),
                                     duration: DateComponents(day: 1),
                                     title: "Paris, France (Vacation)"))
        events.append(calendar.event(calendar: whereCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 17),
                                     duration: DateComponents(day: 1),
                                     title: "Paris, France  (Remote Work)"))
        events.append(calendar.event(calendar: whereCalendar,
                                     start: DateComponents(year: 2024, month: 2, day: 18),
                                     duration: DateComponents(day: 1),
                                     title: "Paris, France (Remote Work)"))

        // London (February 19 - March 17)
        generateWhereEvents(DateComponents(year: 2024, month: 2, day: 19),
                            DateComponents(year: 2024, month: 3, day: 18),
                            "London, UK")

        self.demoCalendars = [
            homeCalendar,
            workCalendar,
            whereCalendar,
        ]

        self.currentYear = 2024
        self.demoEvents = events.sorted { $0.startDate <= $1.endDate }
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
