// Copyright (c) 2021-2022 InSeven Limited
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

import EventKit
import Foundation

extension Calendar {

    func dateInterval(start: Date, duration: DateComponents) throws -> DateInterval {
        guard let end = date(byAdding: duration, to: start) else {
            throw CalendarError.invalidDate
        }
        return DateInterval(start: start, end: end)
    }

    func enumerate(dateInterval: DateInterval, components: DateComponents, block: (DateInterval) -> Void) {
        var date = dateInterval.start
        while date < dateInterval.end {
            guard let nextDate = self.date(byAdding: components, to: date) else {
                // TODO: This is an error?
                return
            }
            block(DateInterval(start: date, end: nextDate))
            date = nextDate
        }
    }

    func date(byAdding dateComponents: [DateComponents], to start: Date) -> DateComponents {
        let end = dateComponents.reduce(start) { date, dateComponents in
            self.date(byAdding: dateComponents, to: date, wrappingComponents: false)!
        }
        return self.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}
