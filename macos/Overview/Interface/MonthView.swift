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

struct MonthView: View {

    let calendar = Calendar.current

    @State var summary: Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter
    }()

    var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()

    var title: String { dateFormatter.string(from: summary.dateInterval.start) }

    var duration: DateComponents {
        calendar.date(byAdding: summary.items.map { $0.duration(calendar: calendar) }, to: summary.dateInterval.start)
    }

    func format(dateComponents: DateComponents) -> String {
        guard let result = dateComponentsFormatter.string(from: dateComponents) else {
            return "Unknown"
        }
        return result
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .lineLimit(1)
                    .font(.headline)
                Spacer()
            }
            Divider()
                .foregroundColor(.secondary)
            if summary.items.count > 0 {
                ForEach(summary.items.sorted(by: { $0.context.title < $1.context.title })) { summary in
                    HStack {
                        Circle()
                            .fill(Color(summary.context.calendar.color))
                            .frame(width: 12, height: 12)
                        Text(summary.context.title)
                            .lineLimit(1)
                        Text("\(summary.uniqueItems.count) events")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(format(dateComponents: summary.duration(calendar: calendar)))
                    }
                }
                Divider()
                    .foregroundColor(.secondary)
            }
            HStack {
                Spacer()
                Text(format(dateComponents: duration))
                    .foregroundColor(.secondary)
            }
        }
        .textSelection(.enabled)
    }

}
