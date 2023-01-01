// Copyright (c) 2021-2023 InSeven Limited
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

    var applicationModel: ApplicationModel

    @AppStorage("Selections") var selectionsStorage: Set<String> = []

    @Published var selections: Set<String> = Set()
    @Published var year: Int = Date.now.year

    @Published var title: String = ""
    @Published var loading = false
    @Published var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

    private let updateQueue = DispatchQueue(label: "WindowModel.updateQueue")
    private var cancellables: Set<AnyCancellable> = []

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        self.selections = selectionsStorage
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))

        // Update the summaries.
        // TODO: Set loading
        $year
            .combineLatest(applicationModel.$calendars, $selections, applicationModel.updates)
            .receive(on: updateQueue)
            .map { (year, calendars, selections, _) in
                return (year, calendars.filter { selections.contains($0.calendarIdentifier) })
            }
            .map { (year, calendars) in
                guard !calendars.isEmpty else {
                    return []
                }
                return (try? self.applicationModel.summary(year: year, calendars: calendars)) ?? []
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
            .combineLatest(applicationModel.$calendars)
            .map { (selections, calendars) in
                return calendars.filter { selections.contains($0.calendarIdentifier) }
            }
            .map { calendars in
                return Array(calendars).map({ $0.title }).joined(separator: ", ")
            }
            .receive(on: DispatchQueue.main)
            .sink { title in
                self.title = title
            }
            .store(in: &cancellables)

        // Store the selections.
        $selections
            .receive(on: DispatchQueue.main)
            .sink { selections in
                self.selectionsStorage = selections
            }
            .store(in: &cancellables)

    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }


}
