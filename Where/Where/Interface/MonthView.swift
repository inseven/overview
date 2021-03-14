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

extension Calendar {

    func date(byAdding dateComponents: [DateComponents], to start: Date) -> DateComponents {
        let end = dateComponents.reduce(start) { date, dateComponents in
            self.date(byAdding: dateComponents, to: date, wrappingComponents: false)!
        }
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}

extension Summary where Item: EKEvent {

    var uniqueItems: [Item] { Array(Set(items)) }

    var duration: DateComponents {
        Calendar.current.date(byAdding: uniqueItems.map { $0.components(bounds: dateInterval) }, to: dateInterval.start)
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

    var duration: DateComponents {
        Calendar.current.date(byAdding: summary.items.map { $0.duration }, to: summary.dateInterval.start)
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
                        Text(format(dateComponents: summary.duration))
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
    }

}
