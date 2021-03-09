//
//  PlaceholderView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import SwiftUI

struct PlaceholderView: View {

    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .background(Color(NSColor.textBackgroundColor))
    }

}
