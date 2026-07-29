// Copyright (c) 2021-2026 Jason Morley
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

struct PeriodSummaryView: View {

    static var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()

    let calendar = Calendar.current

    let summary: PeriodSummary

    init(summary: PeriodSummary) {
        self.summary = summary
    }
    
    func format(dateComponents: DateComponents, startDate: Date) -> String {
        guard let result = Self.dateComponentsFormatter.string(from: dateComponents, startDate: startDate) else {
            return "Unknown"
        }
        return result
    }

    var body: some View {
        VStack {
            if summary.items.count > 0 {
                ForEach(summary.items.sorted(by: { $0.context.title < $1.context.title })) { summary in
                    HStack {
                        CalendarMarker(summary.context.calendar)
                        Text(summary.context.title)
                            .lineLimit(1)
                        EventPopover(summary: summary)
                        Spacer()
                        Text(format(dateComponents: summary.duration(calendar: calendar), startDate: summary.startDate))
                    }
                }
                Divider()
                    .foregroundStyle(.secondary)
            }
            HStack {
                Spacer()
                Text(format(dateComponents: summary.duration(calendar: calendar), startDate: summary.startDate))
                    .foregroundStyle(.secondary)
            }
        }
        .textSelection(.enabled)
    }

}
