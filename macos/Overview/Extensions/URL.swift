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

extension URL {

    static let settingsPrivacyCalendars = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!

    static let donate = URL(string: "https://jbmorley.co.uk/support")!
    static let gitHub = URL(string: "https://github.com/inseven/overview")!
    static let privacyPolicy = URL(string: "https://overview.jbmorley.co.uk/privacy-policy")!
    static let software = URL(string: "https://jbmorley.co.uk/software")!
    static let website = URL(string: "https://overview.jbmorley.co.uk")!

    static var support: URL = {
        let subject = "Overview Support (\(Bundle.main.extendedVersion ?? "Unknown Version"))"
        return URL(address: "support@jbmorley.co.uk", subject: subject)!
    }()

}
