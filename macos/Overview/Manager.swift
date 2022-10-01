// Copyright (c) 2021-2022 InSeven Limited
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

enum CalendarError: Error {
    case failure
    case unknownCalendar
    case invalidDate
}

class Manager: ObservableObject {

    fileprivate let store = EKEventStore()
    fileprivate let calendar = Calendar.current

    let updateQueue = DispatchQueue(label: "Manager.updateQueue")

    @Published var calendars: [EKCalendar] = []
    @Published var years: [Int] = [Date.now.year]
    @Published var year: Int = Date.now.year

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
        updateQueue.async {
            let contributingCalendars = self.calendars.filter { $0.type != .birthday }
            let earliestDate = self.store.earliestEventStartDate(calendars: contributingCalendars) ?? .now
            let years = Array((earliestDate.year...Date.now.year).reversed())
            DispatchQueue.main.async {
                self.years = years
            }
        }
    }

    func summary(year: Int,
                 calendars: [EKCalendar]) throws -> [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] {
        try store.summary(calendar: calendar, year: year, calendars: calendars)
    }

}
