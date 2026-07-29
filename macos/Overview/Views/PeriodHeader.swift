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

import SwiftUI

struct PeriodHeader: View {

    static var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()

    let granularity: Granularity
    let summary: PeriodSummary

    init(granularity: Granularity, summary: PeriodSummary) {
        self.granularity = granularity
        self.summary = summary
    }

    var duration: String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day], from: summary.dateInterval.start, to: summary.dateInterval.end)
        guard let result = Self.dateComponentsFormatter.string(from: dateComponents, startDate: summary.dateInterval.start) else {
            return "Unknown"
        }
        return result
    }

    var title: String {
        switch granularity {
        case .weekly:
            return DateFormatter.weeklyTitleDateFormatter.string(from: summary.dateInterval.start)
        case .monthly:
            return DateFormatter.monthlyTitleDateFormatter.string(from: summary.dateInterval.start)
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .lineLimit(1)
                Spacer()
                Text(duration)
            }
            .font(.headline)
            Divider()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.top)
        .background(.bar)
    }

}
