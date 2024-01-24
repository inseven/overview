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

import Combine
import EventKit
import Foundation
import SwiftUI

class ApplicationModel: ObservableObject {

    enum State {
        case unknown
        case authorized
        case unauthorized
    }

    enum StoreType {
        case eventKit
        case demo
    }

    @Published var state: State = .unknown
    @Published var error: Error? = nil
    @Published var calendars: [CalendarInstance] = []
    @Published var years: [Int] = [Date.now.year]
    @Published var useDemoData: Bool = false
    let updates: AnyPublisher<Notification, Never>

    private let store = EKEventStore()
    private let calendar = Calendar.current
    private let updateQueue = DispatchQueue(label: "CalendarModel.updateQueue")
    private var cancellables: Set<AnyCancellable> = []

    private let applicationWillBecomeActive: AnyPublisher<Notification, Never>

    static private let demoStore = DemoStore()

    init() {
        updates = NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: store)
            .prepend(Notification(name: .EKEventStoreChanged))
            .eraseToAnyPublisher()
        applicationWillBecomeActive = NotificationCenter.default.applicationWillBecomeActive()
    }

    private func requestAccess() {
        dispatchPrecondition(condition: .onQueue(.main))
        store.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error
                    return
                }
                self.state = granted ? .authorized : .unauthorized
            }
        }
    }

    func store(type: StoreType) -> CalendarStore {
        switch type {
        case .eventKit:
            return store
        case .demo:
            return Self.demoStore
        }
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        // Request access whenever the application is foregrounded and we don't yet have access.
        applicationWillBecomeActive
            .combineLatest($state
                .map { state in
                    // This map might seem a little murky but it allows is to flatten the tristate (unknown, authorized,
                    // and unauthorized) into a simple boolean (does/doesn't have access). We model the 'unknown' state
                    // to ensure the UI doesn't bounce through an unauthorized screen on first run, but flatten it into
                    // a simple boolean state here as we _always_ want to request access when we don't have it, but
                    // don't want to treat unknown and unauthorized differently (which could cause over-requesting).
                    return state == .authorized
                }
                .removeDuplicates())
            .filter {
                $0.1 != true
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Requesting access...")
                self?.requestAccess()
            }
            .store(in: &cancellables)

        // Update the calendars whenever access is newly granted or the store changes.
        $state
            .filter { $0 == .authorized }
            .combineLatest(updates, $useDemoData)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .map { _, _, useDemoData in
                return self.store(type: useDemoData ? .demo : .eventKit).calendars()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.calendars, on: self)
            .store(in: &cancellables)

        // Update the data whenever access is newly granted or the store updates.
        $state
            .filter { $0 == .authorized }
            .combineLatest(updates, $calendars.filter({ !$0.isEmpty }), $useDemoData)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .map { _, _, calendars, useDemoData in
                return self.store(type: useDemoData ? .demo : .eventKit).activeYears(for: calendars)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.years, on: self)
            .store(in: &cancellables)
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }

    func summary(year: Int, calendars: [CalendarInstance]) throws -> [MonthlySummary] {
        return try store(type: useDemoData ? .demo : .eventKit).summary(calendar: calendar,
                                                                        year: year,
                                                                        calendars: calendars)
    }

}
