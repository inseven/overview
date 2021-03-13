//
//  MonthView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

struct MonthView: View {

    @State var summary: Summary<Summary<EKEvent>>

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter
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
                        Text("\(summary.items.count)")
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
