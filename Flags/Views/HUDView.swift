//  HUDView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Top bar: timer + score. `TimelineView` only refreshes presentation;
/// `GameTimer` owns expiration and emits the state-changing event.
struct HUDView: View {
  let timerSession: GameTimer.Session
  let score: Int
  let best: Int?

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1.0)) { _ in
      let timer = timerSession.snapshot()

      VStack(spacing: 6) {
        HStack {
          HStack(spacing: 6) {
            Image(systemName: "timer")
              .scaleEffect(timer.isUrgent ? 1.08 : 1)
              .animation(
                timer.isUrgent
                  ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default,
                value: timer.isUrgent
              )
            Text("\(timer.seconds)s")
              .contentTransition(.numericText(countsDown: true))
              .animation(.default, value: timer.seconds)
          }
          .font(.title2.monospacedDigit().bold())
          .foregroundStyle(timer.isUrgent ? .red : .primary)
          .accessibilityLabel(Text("Time left: \(timer.seconds) seconds"))

          Spacer()

          VStack(alignment: .trailing, spacing: 0) {
            Text("Score: \(score)")
              .font(.title2.bold())
              .monospacedDigit()
              .contentTransition(.numericText())
              .animation(.default, value: score)
            if let best {
              Text("Best: \(best)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
          }
        }
        ProgressView(value: timer.remaining, total: timer.total)
          .tint(timer.isUrgent ? .red : .accentColor)
      }
    }
  }
}

#Preview("Full time") {
  HUDView(timerSession: GameTimer().makeSession(), score: 0, best: nil)
    .padding()
}

#Preview("Urgent") {
  HUDView(
    timerSession: GameTimer().makeSession(duration: 8),
    score: 7,
    best: 13
  )
  .padding()
}
