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

import Combine
import EventKit
import Foundation
import SwiftUI

import Interact

@Observable
class SummaryViewModel: Runnable {

    private let applicationModel: ApplicationModel
    private let calendars: [CalendarInstance]
    private let granularity: Granularity
    private let year: Int

    var loading = true

    private let updateQueue = DispatchQueue(label: "WindowModel.updateQueue")
    private var cancellables: Set<AnyCancellable> = []

    init(applicationModel: ApplicationModel, calendars: [CalendarInstance], granularity: Granularity, year: Int) {
        self.applicationModel = applicationModel
        self.calendars = calendars
        self.granularity = granularity
        self.year = year
    }

    var title: String {
        return Array(calendars).map({ $0.title }).joined(separator: ", ")
    }

    var summaries: [PeriodSummary] = []

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        applicationModel.updates
            .receive(on: DispatchQueue.main)
            .map { contents in
                self.loading = true
                return contents
            }
            .receive(on: updateQueue)
            .map { (_) in
                return (try? self.applicationModel.summary(year: self.year,
                                                           calendars: self.calendars,
                                                           granularity: self.granularity.dateComponents)) ?? []
            }
            .receive(on: DispatchQueue.main)
            .sink { (summaries: [PeriodSummary]) in
                self.summaries = summaries
                self.loading = false
            }
            .store(in: &cancellables)

    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }

}
