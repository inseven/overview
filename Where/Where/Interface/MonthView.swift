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

    var components: DateComponents {
        // TODO: Use the calendar from the calendar?
        // TODO: More components?
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: endDate)
    }

}

extension Summary where Item: EKEvent {

    var duration: TimeInterval {
        Set(items).reduce(0.0) { total, event in total + event.duration }
    }

    var components: DateComponents {
        guard let event = items.first else {
            return DateComponents()
        }
        return event.components
    }

}

struct MonthView: View {

    @State var summary: Summary<Summary<EKEvent>>

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter
    }()

    var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current  // TODO: Is this needed?
        formatter.unitsStyle = .full
        return formatter
    }()

    var title: String { dateFormatter.string(from: summary.dateInterval.start) }

    var total: Int {
        summary.items.reduce(0) { $0 + $1.items.count }
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
                        Text(summary.items[0].title ?? "Unknown")
                            .lineLimit(1)
                        Spacer()
                        Text("\(summary.items.count) events")
                        Text("\(dateComponentsFormatter.string(from: summary.duration) ?? "Cheese")")
//                        Text("\(dateComponentsFormatter.string(from: summary.components) ?? "Cheese")")
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
