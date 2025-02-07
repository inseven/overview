// Copyright (c) 2021-2025 Jason Morley
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

import Foundation

extension DateComponentsFormatter {

    // Curiously this functionality isn't provided out of the box, making it far from obvious how to use
    // `DateComponentsFormatter` to correctly render the duration of a date interval in the context of it's start date.
    // We use this to ensure that 1 month can be correctly displayed as 28 or 29 days in February, but 31 days in
    // January.
    func string(from dateInterval: DateInterval) -> String? {
        return string(from: dateInterval.start, to: dateInterval.end)
    }

    func string(from dateComponents: DateComponents, startDate: Date) -> String? {
        let calendar = self.calendar ?? Calendar.autoupdatingCurrent
        guard let endDate = calendar.date(byAdding: dateComponents, to: startDate) else {
            return nil
        }
        return string(from: startDate, to: endDate)
    }

}
