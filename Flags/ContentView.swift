//
//  ContentView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT
//

import Dependencies
import SQLiteData
import SwiftUI

/// Root: owns the ViewModel and switches between loading / ready / playing / finished.
struct ContentView: View {
  @Environment(GameViewModel.self) private var viewModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase

  // Best comes straight from the database (nil = no games yet) and stays
  // live when CloudKit delivers results from other devices.
  @FetchOne(GameResult.order { $0.score.desc() }.select(\.score).limit(1)) var best: Int?

  var body: some View {
    Group {
      switch viewModel.phase {
      case .loading:
        if let error = viewModel.loadError {
          ContentUnavailableView(
            "Could not load flags",
            systemImage: "flag.slash",
            description: Text(error)
          )
        } else {
          ProgressView("Loading flags…")
        }
      case .ready:
        StartView(
          best: best,
          language: viewModel.language,
          onLanguage: { viewModel.language = $0 },
          onPlay: { viewModel.start() }
        )
        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
      case .playing:
        if let question = viewModel.question, let timerSession = viewModel.timerSession {
          GameView(
            question: question,
            lastResult: viewModel.lastResult,
            timerSession: timerSession,
            score: viewModel.score,
            best: best,
            language: viewModel.language,
            onAnswer: { viewModel.answer($0) }
          )
          .transition(reduceMotion ? .opacity : .slide.combined(with: .opacity))
        } else {
          ProgressView("Loading flags…")
        }
      case .finished:
        ResultView(
          score: viewModel.score,
          rounds: viewModel.rounds,
          best: best,
          onReplay: { viewModel.playAgain() },
          goHome: { viewModel.phase = .ready }
        )
        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
      }
    }
    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: viewModel.phase)
    .environment(\.locale, viewModel.language.locale)
    .frame(maxWidth: 640)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .task { viewModel.load() }
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        viewModel.reconcileTimer()
      }
    }
  }
}

#Preview(
  traits: .dependencies {
    try $0.bootstrapDatabase()
  }
) {
  ContentView()
    .environment(GameViewModel())
}
