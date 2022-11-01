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
import SwiftUI

import Interact

struct ContentView: View {

    @ObservedObject var manager: Manager
    @State var selections: Set<EKCalendar> = Set()
    @State var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

    @State private var sort: Int = 0

    @State private var loading = false

    @State var isOn = false

    var title: String {
        let calendars = Array(selections)
        return calendars.map({ $0.title }).joined(separator: ", ")
    }

    func update() {
        loading = true
        DispatchQueue.global(qos: .userInteractive).async {
            let summaries = (try? manager.summary(year: manager.year, calendars: Array(selections))) ?? []
            DispatchQueue.main.async {
                self.summaries = summaries
                self.loading = false
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            CalendarList(manager: manager, selections: $selections)
        } detail: {
            HStack {
                if loading {
                    Placeholder {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                } else if summaries.count > 0 {
                    YearView(summaries: summaries)
                } else {
                    Placeholder("No Events")
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Picker("Year", selection: $manager.year) {
                        ForEach(manager.years) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }
            }
        }
        .onChange(of: selections) { selections in
            update()
        }
        .onChange(of: manager.year) { year in
            update()
        }
    }
}
