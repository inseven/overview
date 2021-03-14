//
//  WhereApp.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

extension EKCalendar: Identifiable {
    public var id: String { calendarIdentifier }
}

extension EKCalendarItem: Identifiable {
    public var id: String { calendarItemIdentifier }
}

enum CalendarError: Error {
    case failure
    case unknownCalendar
    case invalidDate
}

struct Summary<Context, Item>: Identifiable {
    var id = UUID()
    var dateInterval: DateInterval
    var context: Context
    var items: [Item]
}

@main
struct WhereApp: App {

    @ObservedObject var manager = Manager()

    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView(manager: manager)
            }
        }
        .commands {
            SidebarCommands()
        }
    }
}
