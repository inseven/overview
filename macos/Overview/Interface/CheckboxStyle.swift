// Copyright (c) 2021-2024 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

struct CheckboxStyle: ToggleStyle {

    let color: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .overlay(RoundedRectangle(cornerRadius: 3)
                                .stroke(color, lineWidth: 1)
                                .brightness(-0.2))
                    .frame(width: 14, height: 14)
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}
