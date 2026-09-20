//  FlagCardView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Center flag card. Narrow input: only what it renders (asset name + feedback tint).
struct FlagCardView: View {
  let assetName: String
  let feedback: AnswerResult?
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var isCorrect: Bool {
    if case .correct = feedback { true } else { false }
  }

  private var isWrong: Bool {
    if case .wrong = feedback { true } else { false }
  }

  var body: some View {
    VStack {
      Image(assetName)
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .bottom) {
          if isCorrect {
            Label("Correct! +1", systemImage: "checkmark")
              .font(.headline.bold())
              .foregroundStyle(.green.contrastingText())
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(.green, in: .capsule)
              .shadow(color: .green.opacity(0.5), radius: 10, y: 4)
              .padding(.bottom, 12)
              .transition(
                reduceMotion
                  ? .opacity
                  : .move(edge: .bottom).combined(with: .scale(scale: 0.8)).combined(with: .opacity)
              )
          }
        }
        .padding(12)
        .background(isCorrect ? .green : isWrong ? .red : cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
          RoundedRectangle(cornerRadius: 20)
            .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
        }
        .shadow(
          color: isCorrect ? .green.opacity(0.25) : isWrong ? .red.opacity(0.25) : .black.opacity(0.15),
          radius: isCorrect ? 30 : isWrong ? 24 : 12,
          y: 8
        )
        .scaleEffect(reduceMotion ? 1 : isCorrect ? 1.02 : isWrong ? 1.03 : 1)
        .animation(
          reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.62),
          value: feedback
        )
        .accessibilityLabel(Text("Flag to guess"))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var cardBackground: Color {
    #if os(iOS)
      Color(.secondarySystemBackground)
    #else
      Color(nsColor: .controlBackgroundColor)
    #endif
  }
}

#Preview("Idle") {
  FlagCardView(assetName: "ck", feedback: nil)
    .padding(60)
}

#Preview("Correct") {
  let country = Country(code: "MK", code3: "MKD", nameEN: "North Macedonia", nameFR: "Macédoine du Nord", emoji: nil)
  return FlagCardView(assetName: "mk", feedback: .correct(country))
    .padding(60)
}

#Preview("Wrong") {
  let picked = Country(code: "FR", code3: "FRA", nameEN: "France", nameFR: "France", emoji: nil)
  let correct = Country(code: "MK", code3: "MKD", nameEN: "North Macedonia", nameFR: "Macédoine du Nord", emoji: nil)
  return FlagCardView(assetName: "mk", feedback: .wrong(picked: picked, correct: correct))
    .padding(60)
}
