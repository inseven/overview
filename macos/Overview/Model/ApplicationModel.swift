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

import Combine
import EventKit
import Foundation
import SwiftUI

class ApplicationModel: ObservableObject {

    @Published var error: Error? = nil
    @Published var calendars: [EKCalendar] = []
    @Published var years: [Int] = [Date.now.year]
    let updates: AnyPublisher<Notification, Never>

    private let store = EKEventStore()
    private let calendar = Calendar.current
    private let updateQueue = DispatchQueue(label: "CalendarModel.updateQueue")
    private var cancellables: Set<AnyCancellable> = []

    init() {
        updates = NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: store)
            .prepend(Notification(name: .EKEventStoreChanged, object: nil, userInfo: nil))
            .eraseToAnyPublisher()

        store.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error
                    return
                }
                if !granted {
                    self.error = OverviewError.accessDenied
                }
            }
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        fetchAvailableYears()

        updates
            .receive(on: updateQueue)
            .map { notification in
                let contributingCalendars = self.calendars.filter { $0.type != .birthday }
                let earliestDate = self.store.earliestEventStartDate(calendars: contributingCalendars) ?? .now
                let years = Array((earliestDate.year...Date.now.year).reversed())
                return years
            }
            .receive(on: DispatchQueue.main)
            .sink { years in
                self.years = years
            }
            .store(in: &cancellables)
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }

    private func fetchAvailableYears() {
        dispatchPrecondition(condition: .onQueue(.main))
        calendars = store.calendars(for: .event)
        DispatchQueue.global(qos: .userInteractive).async {
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
        return try store.summary(calendar: calendar, year: year, calendars: calendars)
    }


}
