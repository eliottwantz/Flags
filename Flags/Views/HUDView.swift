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

  #if os(macOS)
    private var vSpacing: CGFloat { 10 }
    private var hSpacing: CGFloat { 10 }
    private var timerFont: Font { .largeTitle.monospacedDigit().bold() }
    private var scoreFont: Font { .title.bold() }
    private var bestFont: Font { .callout }
  #else
    private var vSpacing: CGFloat { 6 }
    private var hSpacing: CGFloat { 6 }
    private var timerFont: Font { .title2.monospacedDigit().bold() }
    private var scoreFont: Font { .title2.bold() }
    private var bestFont: Font { .caption }
  #endif

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1.0)) { _ in
      let timer = timerSession.snapshot()

      VStack(spacing: vSpacing) {
        HStack {
          HStack(spacing: hSpacing) {
            Image(systemName: "timer")
              .imageScale(.large)
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
          .font(timerFont)
          .foregroundStyle(timer.isUrgent ? .red : .primary)
          .accessibilityLabel(Text("Time left: \(timer.seconds) seconds"))

          Spacer()

          VStack(alignment: .trailing, spacing: 2) {
            Text("Score: \(score)")
              .font(scoreFont)
              .monospacedDigit()
              .contentTransition(.numericText())
              .animation(.default, value: score)
            if let best {
              Text("Best: \(best)")
                .font(bestFont)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
          }
        }
        ProgressView(value: timer.remaining, total: timer.total)
          .tint(timer.isUrgent ? .red : .accentColor)
          #if os(macOS)
            .controlSize(.large)
            .padding(.top, 2)
          #endif
      }
      #if os(macOS)
        .padding(.vertical, 8)
      #endif
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
