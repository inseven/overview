//
//  YearView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

struct YearView: View {

    // TODO: The context should be the year?
    var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

    var body: some View {
        ScrollView {
            VStack {
                ForEach(summaries) { summary in
                    MonthView(summary: summary)
                        .padding(.bottom)
                }
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
        }
        .background(Color(NSColor.textBackgroundColor))
    }

}
