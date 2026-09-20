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
  let best: Int?
  let onReplay: () -> Void
  let goHome: () -> Void

  private var isNewBest: Bool { score > 0 && score >= (best ?? 0) }

  var body: some View {
    VStack(spacing: 16) {
      Spacer()
      Text("Time's up!")
        .font(.largeTitle.bold())
      Text("\(score)")
        .font(.system(size: 80, weight: .black, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(isNewBest ? .yellow : .primary)
        .contentTransition(.numericText())
      if isNewBest {
        Label("New best!", systemImage: "trophy.fill")
          .font(.title)
          .fontWeight(.semibold)
          .foregroundStyle(.yellow)
      } else if let best {
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
      VStack {
        Button("Play again", systemImage: "arrow.clockwise", action: onReplay)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .buttonSizing(.flexible)
          .font(.title3.bold())
          .frame(maxWidth: .infinity)
        Button("Home", systemImage: "house", action: goHome)
          .buttonStyle(.bordered)
          .controlSize(.large)
          .buttonSizing(.flexible)
          .font(.title3.bold())
          .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: 140)
      Spacer()
    }
    .padding()
    .sensoryFeedback(.success, trigger: score)
  }
}

#Preview("New best") {
  ResultView(score: 12, rounds: 15, best: 12, onReplay: {}, goHome: {})
}

#Preview("No new best") {
  ResultView(score: 7, rounds: 10, best: 13, onReplay: {}, goHome: {})
}
