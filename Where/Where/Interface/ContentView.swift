//
//  ContentView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

enum Flavor: String, CaseIterable, Identifiable {
    case chocolate
    case vanilla
    case strawberry

    var id: String { self.rawValue }
}

extension Int: Identifiable {
    public var id: Int { self }
}

struct ContentView: View {

    @ObservedObject var manager: Manager
    @State var selections: Set<EKCalendar> = Set()
    @State var summaries: [Summary<Summary<EKCalendarItem>>] = []

    @State private var sort: Int = 0
    @State private var year: Int = 2021

    @State private var loading = false

    let years = [
        2021,
        2020,
        2019,
        2018,
        2017,
        2016,
        2015,
        2014,
        2013,
        2012,
        2011
    ]

    func update() {
        loading = true
        DispatchQueue.global(qos: .userInteractive).async {
            let summaries = (try? manager.summary(year: year, calendars: Array(selections))) ?? []
            DispatchQueue.main.async {
                self.summaries = summaries
                self.loading = false
            }
        }
    }

    var body: some View {
        NavigationView {
            List(manager.calendars) { calendar in
                HStack {
                    Image(systemName: selections.contains(calendar) ? "checkmark.square" : "square")
                        .foregroundColor(Color(calendar.color))
                    Text(calendar.title)
                }
                .onTapGesture {
                    if selections.contains(calendar) {
                        selections.remove(calendar)
                    } else {
                        selections.insert(calendar)
                    }
                }
            }
            HStack {
                if loading {
                    PlaceholderView {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .controlSize(.small)
                    }
                } else if summaries.count > 0 {
                    YearView(months: summaries)
                } else {
                    PlaceholderView {
                        Text("No Events")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Picker("Year", selection: $year) {
                        ForEach(years) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }
            }
        }
        .onChange(of: selections) { selections in
            update()
        }
        .onChange(of: year) { year in
            update()
        }
    }
}
