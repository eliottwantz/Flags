//  GameView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Playing screen: HUD on top, flag center, 6 answers below.
struct GameView: View {
  let question: GameQuestion
  let lastResult: AnswerResult?
  let endDate: Date
  let score: Int
  let best: Int
  let language: AppLanguage
  let onAnswer: (Country) -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var wrongTrigger: String {
    if case .wrong(let picked, _) = lastResult { picked.id } else { "" }
  }

  var body: some View {
    VStack(spacing: 16) {
      HUDView(endDate: endDate, score: score, best: best)

      FlagCardView(assetName: question.answer.assetName, feedback: lastResult)
        .id(question.answer.id)
        .layoutPriority(1)
        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
        .keyframeAnimator(initialValue: CGFloat(0), trigger: wrongTrigger) { content, value in
          content.offset(x: value)
        } keyframes: { _ in
          KeyframeTrack {
            LinearKeyframe(0, duration: 0.05)
            LinearKeyframe(-10, duration: 0.05)
            LinearKeyframe(10, duration: 0.05)
            LinearKeyframe(-6, duration: 0.05)
            LinearKeyframe(0, duration: 0.05)
          }
        }

      EqualHeightAdaptiveGrid(minimumWidth: 160, columnSpacing: 10, rowSpacing: 10) {
        ForEach(Array(question.options.enumerated()), id: \.element.id) { index, country in
          AnswerButton(
            title: country.displayName(for: language),
            state: state(for: country),
            action: { onAnswer(country) }
          )
          .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")))
          .accessibilityLabel("\(country.displayName(for: language))")
        }
      }
    }
    .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8), value: question)
    .sensoryFeedback(.success, trigger: score)
    .sensoryFeedback(.error, trigger: wrongTrigger)
  }

  private func state(for country: Country) -> AnswerButton.State {
    switch lastResult {
    case nil:
      return .idle
    case .correct(let picked):
      if country == question.answer { return .correct }
      return picked == country ? .correct : .dimmed
    case .wrong(let picked, let correct):
      if country == picked { return .wrong }
      if country == correct { return .correct }
      return .dimmed
    }
  }
}

#Preview("Idle") {
  let answer = Country(code: "VU", code3: "VUT", nameEN: "Vanuatu", nameFR: "Vanuatu", emoji: "🇻🇺")
  let names = ["Suriname", "Netherlands", "Kuwait", "Botswana", "Tajikistan", "Vanuatu"]
  let options = zip(["SR", "NL", "KW", "BW", "TJ", "VU"], names).map { code, name in
    Country(code: code, code3: nil, nameEN: name, nameFR: name, emoji: nil)
  }
  return GameView(
    question: GameQuestion(answer: answer, options: options),
    lastResult: nil,
    endDate: .now.addingTimeInterval(32),
    score: 7,
    best: 13,
    language: .french,
    onAnswer: { _ in }
  )
  .padding()
}

#Preview("Correct") {
  let answer = Country(code: "VU", code3: "VUT", nameEN: "Vanuatu", nameFR: "Vanuatu", emoji: "🇻🇺")
  let names = ["Suriname", "Netherlands", "Kuwait", "Botswana", "Tajikistan", "Vanuatu"]
  let options = zip(["SR", "NL", "KW", "BW", "TJ", "VU"], names).map { code, name in
    Country(code: code, code3: nil, nameEN: name, nameFR: name, emoji: nil)
  }
  return GameView(
    question: GameQuestion(answer: answer, options: options),
    lastResult: .correct(answer),
    endDate: .now.addingTimeInterval(32),
    score: 8,
    best: 13,
    language: .french,
    onAnswer: { _ in }
  )
  .padding()
}

#Preview("Wrong") {
  let answer = Country(code: "VU", code3: "VUT", nameEN: "Vanuatu", nameFR: "Vanuatu", emoji: "🇻🇺")
  let names = ["Suriname", "Netherlands", "Kuwait", "Botswana", "Tajikistan", "Vanuatu"]
  let options = zip(["SR", "NL", "KW", "BW", "TJ", "VU"], names).map { code, name in
    Country(code: code, code3: nil, nameEN: name, nameFR: name, emoji: nil)
  }
  let picked = options[0]
  return GameView(
    question: GameQuestion(answer: answer, options: options),
    lastResult: .wrong(picked: picked, correct: answer),
    endDate: .now.addingTimeInterval(8),
    score: 7,
    best: 13,
    language: .french,
    onAnswer: { _ in }
  )
  .padding()
}
