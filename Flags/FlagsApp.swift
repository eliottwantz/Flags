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
  @AppStorage("appLanguage") var language: AppLanguage = .systemDefault()
  @AppStorage("bestScore") var bestScore = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environment(viewModel)
            .task {
              viewModel.language = language
              viewModel.bestScore = bestScore
            }
        }
    }
}
