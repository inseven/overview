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

import Foundation

protocol Event {

    var startDate: Date! { get set }
    var endDate: Date! { get set }
    var isAllDay: Bool { get set }

}

extension Event {

    func duration(calendar: Calendar, bounds: DateInterval) -> DateComponents {

        // Unfortunately it seems that somewhere along the line, EventKit has started treating all day events and
        // timed events differently--timed events return an endDate that is exclusive, and all day events have an
        // endDate which is inclusive. Given this, we have to check to see if it's an all day event and adjust its end
        // date by 1 second.
        let endDate: Date
        if isAllDay {
            endDate = self.endDate + 1
        } else {
            endDate = self.endDate
        }

        // Determine the bounded start and end dates.
        let start = max(bounds.start, startDate)
        let end = min(bounds.end, endDate)

        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start, to: end)
    }

}
