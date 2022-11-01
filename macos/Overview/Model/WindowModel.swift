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

import Combine
import EventKit
import Foundation
import SwiftUI

class WindowModel: ObservableObject {

    var manager: Manager

    @Published var selections: Set<EKCalendar> = Set()
    @Published var year: Int = Date.now.year

    @Published var title: String = ""
    @Published var loading = false
    @Published var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

    private let updateQueue = DispatchQueue(label: "WindowModel.updateQueue")
    private var cancellables: Set<AnyCancellable> = []

    init(manager: Manager) {
        self.manager = manager
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        // Update the summaries.
        // TODO: Set loading
        $year
            .combineLatest($selections)
            .receive(on: updateQueue)
            .map { return ($0, Array($1)) }
            .map { (year, selections) in
                guard !selections.isEmpty else {
                    return []
                }
                return (try? self.manager.summary(year: year, calendars: selections)) ?? []
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summaries in
                guard let self = self else {
                    return
                }
                self.summaries = summaries
            }
            .store(in: &cancellables)

        // Update the title.
        $selections
            .map { calendars in
                return Array(calendars).map({ $0.title }).joined(separator: ", ")
            }
            .receive(on: DispatchQueue.main)
            .sink { title in
                self.title = title
            }
            .store(in: &cancellables)

    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }


}
