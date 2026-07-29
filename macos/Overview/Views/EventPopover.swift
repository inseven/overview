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

struct EventPopover: View {

    struct LayoutMetrics {
        static let minimumWidth: CGFloat = 280
    }

    static var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()

    static var dateIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.calendar = Calendar.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateStyle = .medium
        return formatter
    }()

    let summary: SimilarEvents

    @State var isPresented = false

    init(summary: SimilarEvents) {
        self.summary = summary
    }

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text("\(summary.uniqueItems.count) events")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented) {
            ScrollView {
                Grid {
                    ForEach(summary.items) { item in
                        GridRow {
                            CalendarMarker(item.calendar)
                            HStack {
                                if item.isAllDay {
                                    Text(Self.dateFormatter.string(from: item.startDate))
                                } else {
                                    Text(Self.dateIntervalFormatter.string(from: item.dateInterval) ?? "Unknown")
                                }
                            }
                            .gridColumnAlignment(.leading)
                            Spacer()
                            Text(Self.dateComponentsFormatter.string(from: item.dateInterval) ?? "Unknown")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .safeAreaPadding()
                .frame(minWidth: LayoutMetrics.minimumWidth)
            }
        }

    }

}
