//
//  FlagsApp.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT
//

import SQLiteData
import SwiftUI

@main
struct FlagsApp: App {
  @State private var viewModel = GameViewModel()

  init() {
    try! prepareDependencies {
      try $0.bootstrapDatabase()
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(viewModel)
    }
  }
}
