//
//  YearView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import EventKit
import SwiftUI

struct YearView: View {

    var months: [Summary<Summary<EKEvent>>] = []

    var body: some View {
        ScrollView {
            VStack {
                ForEach(months) { summary in
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
