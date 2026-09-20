//  HUDView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Top bar: timer + score. Timer is deadline-driven via `TimelineView`,
/// so no per-second state updates flow through the ViewModel.
struct HUDView: View {
  let endDate: Date
  let score: Int
  let best: Int

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1.0)) { context in
      let now = context.date
      let timeLeft = max(0, min(GameViewModel.gameDuration, endDate.timeIntervalSince(now)))
      // ceil keeps "60s" visible for the first full second, then 59, 58…
      let seconds = max(0, Int(ceil(timeLeft)))
      let isUrgent = timeLeft <= GameViewModel.urgentThreshold

      VStack(spacing: 6) {
        HStack {
          HStack(spacing: 6) {
            Image(systemName: "timer")
              .scaleEffect(isUrgent ? 1.08 : 1)
              .animation(
                isUrgent ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default,
                value: isUrgent
              )
            Text("\(seconds)s")
              .contentTransition(.numericText(countsDown: true))
              .animation(.default, value: seconds)
          }
          .font(.title2.monospacedDigit().bold())
          .foregroundStyle(isUrgent ? .red : .primary)
          .accessibilityLabel(Text("Time left: \(seconds) seconds"))

          Spacer()

          VStack(alignment: .trailing, spacing: 0) {
            Text("Score: \(score)")
              .font(.title2.bold())
              .monospacedDigit()
              .contentTransition(.numericText())
            Text("Best: \(best)")
              .font(.caption)
              .foregroundStyle(.secondary)
              .monospacedDigit()
          }
        }
        ProgressView(value: timeLeft, total: GameViewModel.gameDuration)
          .tint(isUrgent ? .red : .accentColor)
      }
    }
  }
}

#Preview("Full time") {
  HUDView(endDate: .now.addingTimeInterval(60), score: 0, best: 0)
    .padding()
}

#Preview("Urgent") {
  HUDView(endDate: .now.addingTimeInterval(8), score: 7, best: 13)
    .padding()
}
