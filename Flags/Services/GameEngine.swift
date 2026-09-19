//  GameEngine.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation

/// One round: guess `answer` from `options`.
struct GameQuestion: Sendable, Equatable {
  let answer: Country
  let options: [Country]

  static func == (lhs: GameQuestion, rhs: GameQuestion) -> Bool {
    lhs.answer == rhs.answer && lhs.options == rhs.options
  }
}

/// Pure game logic. Sendable + no I/O so it stays testable under Swift 6.
struct GameEngine: Sendable {
  static let optionsCount = 6

  /// Picks a question, avoiding `previousAnswer` so flags never repeat back-to-back.
  func makeQuestion(from countries: [Country], previousAnswer: Country? = nil) -> GameQuestion? {
    guard countries.count >= Self.optionsCount else { return nil }
    let candidates = previousAnswer.map { prev in countries.filter({ $0 != prev }) } ?? countries
    guard let answer = candidates.randomElement() else { return nil }
    var distractors = countries.filter { $0 != answer }.shuffled().prefix(Self.optionsCount - 1)
    // Defensive: if pool is exactly 6 and previous was excluded, top up from full list.
    if distractors.count < Self.optionsCount - 1 {
      let topUp = countries.filter { $0 != answer && !distractors.contains($0) }
      distractors += topUp.prefix((Self.optionsCount - 1) - distractors.count)
    }
    let options = ([answer] + distractors).shuffled()
    return GameQuestion(answer: answer, options: options)
  }
}
