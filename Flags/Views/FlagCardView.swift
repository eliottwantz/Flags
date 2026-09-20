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
        .overlay {
          Rectangle()
            .strokeBorder(
              isCorrect ? .green : isWrong ? .red : .secondary.opacity(0),
              lineWidth: 7
            )
        }
        .shadow(
          color: isCorrect ? .green.opacity(0.2) : isWrong ? .red.opacity(0.2) : .black.opacity(0.1),
          radius: isCorrect ? 30 : isWrong ? 24 : 12,
          y: 8
        )
        .scaleEffect(reduceMotion ? 1 : isCorrect ? 1.02 : isWrong ? 1.03 : 1)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(
          reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.62),
          value: feedback
        )
        .accessibilityLabel(Text("Flag to guess"))
    }
    .padding(20)
    #if os(iOS)
      .frame(maxWidth: 300, maxHeight: 300)
    #else
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    #endif
  }
}

#Preview("Idle") {
  FlagCardView(assetName: "ck", feedback: nil)
    .padding(60)
}

#Preview("Correct") {
  let country = Country(code: "MK", code3: "MKD", name_en: "North Macedonia", name_fr: "Macédoine du Nord", emoji: nil)
  return FlagCardView(assetName: "mk", feedback: .correct(country))
    .padding(60)
}

#Preview("Wrong") {
  let picked = Country(code: "FR", code3: "FRA", name_en: "France", name_fr: "France", emoji: nil)
  let correct = Country(code: "MK", code3: "MKD", name_en: "North Macedonia", name_fr: "Macédoine du Nord", emoji: nil)
  return FlagCardView(assetName: "mk", feedback: .wrong(picked: picked, correct: correct))
    .padding(60)
}
