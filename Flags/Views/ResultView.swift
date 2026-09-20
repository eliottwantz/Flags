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

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var scoreAppeared = false
  @State private var medallionAppeared = false
  @State private var badgeAppeared = false
  @State private var controlsAppeared = false

  var body: some View {
    VStack(spacing: 16) {
      Spacer()
      if isNewBest {
        Text("Time's up!")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.secondary)
          .textCase(.uppercase)
          .tracking(3)
          .opacity(scoreAppeared ? 1 : 0)
        Text("New Record!")
          .font(.system(size: 44, weight: .black, design: .rounded))
          .foregroundStyle(
            LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
          )
          .shadow(color: .orange.opacity(scoreAppeared ? 0.5 : 0), radius: 18)
          .scaleEffect(scoreAppeared ? 1 : 0.4)
          .opacity(scoreAppeared ? 1 : 0)
          .rotationEffect(.degrees(scoreAppeared ? 0 : -5))
        TrophyMedallion(appeared: medallionAppeared)
      } else {
        Text("Time's up!")
          .font(.largeTitle.bold())
      }
      Text("\(score)")
        .font(.system(size: 80, weight: .black, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(
          isNewBest
            ? AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
            : AnyShapeStyle(.primary)
        )
        .contentTransition(.numericText())
        .scaleEffect(scoreAppeared ? 1 : (isNewBest ? 0.3 : 0.8))
        .opacity(scoreAppeared ? 1 : 0)
        .rotationEffect(.degrees(scoreAppeared ? 0 : (isNewBest ? -8 : 0)))
        .shadow(color: isNewBest ? .yellow.opacity(badgeAppeared ? 0.6 : 0) : .clear, radius: 24)
      if !isNewBest, let best {
        Text("Best: \(best)")
          .font(.headline)
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .opacity(scoreAppeared ? 1 : 0)
          .offset(y: scoreAppeared ? 0 : 8)
      }
      if rounds > 0 {
        Text("\(rounds) flags seen")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .opacity(controlsAppeared ? 1 : 0)
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
      .opacity(controlsAppeared ? 1 : 0)
      .offset(y: controlsAppeared ? 0 : 20)
      Spacer()
    }
    .padding()
    .sensoryFeedback(.success, trigger: score)
    .sensoryFeedback(.success, trigger: medallionAppeared)
    .sensoryFeedback(.success, trigger: badgeAppeared)
    .onAppear {
      if reduceMotion {
        scoreAppeared = true
        medallionAppeared = true
        badgeAppeared = true
        controlsAppeared = true
      } else if isNewBest {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1)) {
          scoreAppeared = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.5).delay(0.35)) {
          medallionAppeared = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.5).delay(0.65)) {
          badgeAppeared = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.9)) {
          controlsAppeared = true
        }
      } else {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
          scoreAppeared = true
        }
        controlsAppeared = true
      }
    }
  }
}

/// Popping trophy with rotating sunburst rays and pulsing rings.
private struct TrophyMedallion: View {
  let appeared: Bool

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      if !reduceMotion {
        ExpandingRing(appeared: appeared, diameter: 132, duration: 1.6)
        ExpandingRing(appeared: appeared, diameter: 168, duration: 2.2)
      }
      Image(systemName: "trophy.fill")
        .font(.system(size: 64))
        .foregroundStyle(.yellow)
        .shadow(color: .yellow.opacity(appeared ? 0.7 : 0), radius: 26)
        .scaleEffect(appeared ? 1 : 0.2)
        .rotationEffect(.degrees(appeared ? 0 : -25))
        .phaseAnimator(reduceMotion ? [0.0] : [-5.0, 5.0]) { content, float in
          content.offset(y: float)
        } animation: { _ in
          .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
        }
    }
    .frame(height: 180)
    .frame(maxWidth: .infinity)
  }
}

/// Endlessly expanding + fading pulse ring.
private struct ExpandingRing: View {
  let appeared: Bool
  let diameter: CGFloat
  let duration: Double

  var body: some View {
    Circle()
      .stroke(
        LinearGradient(colors: [.yellow, .orange.opacity(0.2)], startPoint: .top, endPoint: .bottom),
        lineWidth: 3
      )
      .frame(width: diameter, height: diameter)
      .opacity(appeared ? 1 : 0)
      .phaseAnimator([0.0, 1.0]) { content, phase in
        content.scaleEffect(0.85 + 0.25 * phase).opacity(0.8 - 0.8 * phase)
      } animation: { _ in
        .easeOut(duration: duration).repeatForever(autoreverses: false)
      }
  }
}

#Preview("New best") {
  ResultView(score: 12, rounds: 15, best: 12, onReplay: {}, goHome: {})
}

#Preview("No new best") {
  ResultView(score: 7, rounds: 10, best: 13, onReplay: {}, goHome: {})
}
