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


// TODO: Move the calendar list out

struct CheckboxStyle: ToggleStyle {

    let color: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color)
                    .overlay(RoundedRectangle(cornerRadius: 2)
                                .stroke(color, lineWidth: 1)
                                .brightness(-0.2))
                    .frame(width: 14, height: 14)
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .foregroundColor(color)
                        .brightness(-0.4)
                }
            }
                configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}

struct ContentView: View {

    @ObservedObject var manager: Manager
    @State var selections: Set<EKCalendar> = Set()
    @State var summaries: [Summary<Array<EKCalendar>, Summary<CalendarItem, EKEvent>>] = []

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

    @State var isOn = false

    var title: String {
        let calendars = Array(selections)
        return calendars.map({ $0.title }).joined(separator: ", ")
    }

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
                    Toggle(isOn: Binding(get: {
                        selections.contains(calendar)
                    }, set: { selected in
                        if selected {
                            selections.insert(calendar)
                        } else {
                            selections.remove(calendar)
                        }
                    })) {
                        Text(calendar.title)
                    }
                    .toggleStyle(CheckboxStyle(color: Color(calendar.color)))
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
                    }
                } else if summaries.count > 0 {
                    YearView(summaries: summaries)
                } else {
                    PlaceholderView {
                        Text("No Events")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(title)
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
