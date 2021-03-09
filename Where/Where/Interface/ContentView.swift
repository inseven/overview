//
//  ContentView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

struct ContentView: View {

    @ObservedObject var manager: Manager
    @State var selectedCalendarIdentifier: String?
    @State var summaries: [Summary<Summary<EKCalendarItem>>] = []

    var body: some View {
        NavigationView {
            List(manager.calendars, selection: $selectedCalendarIdentifier) { calendar in
                HStack {
                    Circle()
                        .fill(Color(calendar.color))
                        .frame(width: 12, height: 12)
                    Text(calendar.title)
                }
            }
            if summaries.count > 0 {
                YearView(months: summaries)
            } else {
                PlaceholderView("No Events")
            }
        }
        .onChange(of: selectedCalendarIdentifier) { selectedCalendarIdentifier in
            guard let selectedCalendarIdentifier  = selectedCalendarIdentifier else {
                return
            }
            summaries = (try? manager.summaries(calendarIdentifier: selectedCalendarIdentifier)) ?? []
        }
    }
}
