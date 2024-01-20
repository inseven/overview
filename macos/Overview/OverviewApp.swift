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

import EventKit
import SwiftUI

import Diligence
import Interact

@main
struct OverviewApp: App {

    @ObservedObject var applicationModel = ApplicationModel()

    init() {
        applicationModel.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(applicationModel: applicationModel)
        }
        .commands {
            SidebarCommands()
        }
        .defaultSize(CGSize(width: 800, height: 800))

        About(repository: "inseven/overview", copyright: "Copyright © 2021-2024 Jason Morley") {
            Action("Website", url: URL(string: "https://overview.jbmorley.co.uk")!)
            Action("Privacy Policy", url: URL(string: "https://overview.jbmorley.co.uk/privacy-policy")!)
            Action("GitHub", url: URL(string: "https://github.com/inseven/overview")!)
        } acknowledgements: {
            Acknowledgements("Developers") {
                Credit("Jason Morley", url: URL(string: "https://jbmorley.co.uk"))
            }
            Acknowledgements("Thanks") {
                Credit("Joanne Wong")
                Credit("Lukas Fittl")
                Credit("Michael Dales")
                Credit("Sara Frederixon")
                Credit("Sarah Barbour")
            }
        } licenses: {
            License("Overview", author: "Jason Morley", filename: "overview-license")
            License(Interact.Package.name, author: Interact.Package.author, url: Interact.Package.licenseURL)
            License("Material Icons", author: "Google", filename: "material-icons-license")
        }

    }
}
