// Copyright (c) 2021 Jason Barrie Morley
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

// TODO: Move the calendar list out

struct ContentView: View {

    @ObservedObject var manager: Manager
    @State var selections: Set<EKCalendar> = Set()
    @State var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

    @State private var sort: Int = 0
    @State private var year: Int = 2021

    @State private var loading = false

    let years = [
        2021,
        2020,
        2019,
        2018,
        2017,
        2016,
        2015,
        2014,
        2013,
        2012,
        2011
    ]

    @State var isOn = false

    var title: String {
        let calendars = Array(selections)
        return calendars.map({ $0.title }).joined(separator: ", ")
    }

    func update() {
        loading = true
        DispatchQueue.global(qos: .userInteractive).async {
            let calendar = Calendar.current
            let summaries = (try? manager.summary(calendar: calendar, year: year, calendars: Array(selections))) ?? []
            DispatchQueue.main.async {
                self.summaries = summaries
                self.loading = false
            }
        }
    }

    var body: some View {
        NavigationView {
            List(manager.calendars) { calendar in
                HStack {
                    Toggle(isOn: Binding(get: {
                        selections.contains(calendar)
                    }, set: { selected in
                        if selected {
                            selections.insert(calendar)
                        } else {
                            selections.remove(calendar)
                        }
                    })) {
                        Text(calendar.title)
                    }
                    .toggleStyle(CheckboxStyle(color: Color(calendar.color)))
                }
                .onTapGesture {
                    if selections.contains(calendar) {
                        selections.remove(calendar)
                    } else {
                        selections.insert(calendar)
                    }
                }
            }
            HStack {
                if loading {
                    PlaceholderView {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    }
                } else if summaries.count > 0 {
                    YearView(summaries: summaries)
                } else {
                    PlaceholderView {
                        Text("No Events")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Picker("Year", selection: $year) {
                        ForEach(years) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }
            }
        }
        .onChange(of: selections) { selections in
            update()
        }
        .onChange(of: year) { year in
            update()
        }
    }
}
