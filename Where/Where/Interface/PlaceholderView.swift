//
//  PlaceholderView.swift
//  Where
//
//  Created by Jason Barrie Morley on 08/03/2021.
//

import SwiftUI

struct PlaceholderView<Content: View>: View {

    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }

}
