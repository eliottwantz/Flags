//
//  FlagsApp.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT
//

import SwiftUI

@main
struct FlagsApp: App {
  @State private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environment(viewModel)
        }
    }
}
