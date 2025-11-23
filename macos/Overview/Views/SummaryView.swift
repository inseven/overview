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

import EventKit
import SwiftUI

import Interact

struct SummaryView: View {

    struct LayoutMetrics {
        static let minWidth = 500.0
        static let minHeight = 400.0
    }

    @Environment(\.openURL) var openURL

    @ObservedObject var applicationModel: ApplicationModel

    private let granularity: Granularity

    @State private var windowModel: SummaryViewModel

    init(applicationModel: ApplicationModel, calendars: [CalendarInstance], granularity: Granularity, year: Int) {
        self.applicationModel = applicationModel
        self.granularity = granularity
        _windowModel = State(wrappedValue: SummaryViewModel(applicationModel: applicationModel,
                                                            calendars: calendars,
                                                            granularity: granularity,
                                                            year: year))
    }

    func title(for summary: PeriodSummary) -> String {
        switch granularity {
        case .weekly:
            return DateFormatter.weeklyTitleDateFormatter.string(from: summary.dateInterval.start)
        case .monthly:
            return DateFormatter.monthlyTitleDateFormatter.string(from: summary.dateInterval.start)
        }
    }

    var body: some View {
        HStack {
            if windowModel.loading {
                PlaceholderView {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            } else if !windowModel.summaries.isEmpty {
                YearSummaryView(summaries: windowModel.summaries) { summary in
                    title(for: summary)
                }
            } else {
                switch applicationModel.state {
                case .unknown:
                    ProgressView()
                        .progressViewStyle(.circular)
                case .authorized:
                    ContentUnavailableView {
                        Label("No Calendars Selected", systemImage: "calendar")
                    } description: {
                        Text("Select one or more calendars from the sidebar.")
                    }
                case .unauthorized:
                    ContentUnavailableView {
                        Label("Limited Calendar Access", systemImage: "calendar")
                    } description: {
                        Text("Overview needs full access to your calendar to be able to display and summarize your events.",
                             comment: "Calendar privacy usage description shown when the user has denied acccess.")
                        Button {
                            openURL(.settingsPrivacyCalendars)
                        } label: {
                            Text("Open Privacy Settings", comment: "Title of the button that opens System Settings.")
                        }
                    }
                }
            }
        }
        .frame(minWidth: LayoutMetrics.minWidth, minHeight: LayoutMetrics.minHeight)
        .navigationTitle(Text("Overview", comment: "Main window title."))
        .navigationSubtitle(windowModel.title)
        .runs(windowModel)
        .environment(windowModel)
    }

}
