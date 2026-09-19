//  ResultView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// End-of-game screen: score, accuracy, best, play again.
struct ResultView: View {
  let score: Int
  let rounds: Int
  let best: Int
  let onReplay: () -> Void

  private var isNewBest: Bool { score > 0 && score >= best }

  var body: some View {
    VStack(spacing: 16) {
      Spacer()
      Text("Time's up!")
        .font(.largeTitle.bold())
      Text("\(score)")
        .font(.system(size: 80, weight: .black, design: .rounded))
        .monospacedDigit()
        .contentTransition(.numericText())
      if isNewBest {
        Label("New best!", systemImage: "trophy.fill")
          .font(.headline)
          .foregroundStyle(.yellow)
      } else {
        Text("Best: \(best)")
          .font(.headline)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      if rounds > 0 {
        Text("\(rounds) flags seen")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Button("Play again", systemImage: "arrow.clockwise", action: onReplay)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .font(.title3.bold())
      Spacer()
    }
    .padding()
    .sensoryFeedback(.success, trigger: score)
  }
}
