//  HUDView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Top bar: timer + score. Narrow inputs so only the HUD invalidates each tick.
struct HUDView: View {
  let timeLeft: Double
  let score: Int
  let best: Int
  let isUrgent: Bool
  let language: AppLanguage

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Label(
          "\(Int(timeLeft))s",
          systemImage: "timer"
        )
        .font(.title2.monospacedDigit().bold())
        .foregroundStyle(isUrgent ? .red : .primary)
        .scaleEffect(isUrgent ? 1.08 : 1)
        .animation(isUrgent ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isUrgent)
        .accessibilityLabel("Time left: \(Int(timeLeft)) seconds")

        Spacer()

        VStack(alignment: .trailing, spacing: 0) {
          Text(language == .french ? "Score : \(score)" : "Score: \(score)")
            .font(.title2.bold())
            .monospacedDigit()
            .contentTransition(.numericText())
          Text(language == .french ? "Record : \(best)" : "Best: \(best)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
      }
      ProgressView(value: max(0, timeLeft), total: GameViewModel.gameDuration)
        .tint(isUrgent ? .red : .accentColor)
    }
  }
}
