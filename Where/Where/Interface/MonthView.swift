//
//  MonthView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

extension EKEvent {

    var duration: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }

    func duration(bounds: DateInterval) ->  TimeInterval {
        let start = max(bounds.start, startDate)
        let end = min(bounds.end, endDate)
        return end.timeIntervalSince(start)
    }

    func components(bounds: DateInterval) -> DateComponents {
        // TODO: Use the calendar from the calendar?
        // TODO: More components?
        let start = max(bounds.start, startDate)
        let end = min(bounds.end, endDate)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}

extension Summary where Item: EKEvent {

    var uniqueItems: [Item] { Array(Set(items)) }

    var components: DateComponents {
        let calendar = Calendar.current  // TODO: Use the correct calendar!
        let start = dateInterval.start
        let end = uniqueItems.reduce(start) { date, event in
            calendar.date(byAdding: event.components(bounds: dateInterval), to: date, wrappingComponents: false)!  // TODO: Don't crash
        }
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}

struct MonthView: View {

    @State var summary: Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter
    }()

    var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current  // TODO: Is this needed?
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()

    var title: String { dateFormatter.string(from: summary.dateInterval.start) }

    var total: Int {
        summary.items.reduce(0) { $0 + $1.items.count }
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
                ForEach(summary.items) { summary in
                    HStack {
                        Circle()
                            .fill(Color(summary.context.calendar.color))
                            .frame(width: 12, height: 12)
                        Text(summary.items[0].title ?? "Unknown")
                            .lineLimit(1)
                        Text("(\(summary.uniqueItems.count) events)")
                        Spacer()
                        Text(format(dateComponents: summary.components))
                    }
                }
                Divider()
                    .foregroundColor(.secondary)
            }
            HStack {
                Spacer()
                Text("\(total)")
                    .foregroundColor(.secondary)
            }
        }
    }

}
