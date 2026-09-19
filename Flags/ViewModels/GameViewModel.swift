//  GameViewModel.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation
import SwiftUI

enum GamePhase: Sendable, Equatable {
  case loading
  case ready
  case playing
  case finished
}

enum AnswerResult: Sendable, Equatable {
  case correct(Country)
  case wrong(picked: Country, correct: Country)
}

/// Single source of truth for the 1-minute game. `@MainActor` + `@Observable` per SwiftUI dataflow.
@Observable
@MainActor
final class GameViewModel {
  static let gameDuration: Double = 60

  var phase: GamePhase = .loading
  var countries: [Country] = []
  var question: GameQuestion?
  var score = 0
  var rounds = 0
  var timeLeft: Double = gameDuration
  var lastResult: AnswerResult?
  var loadError: String?
  var language: AppLanguage = .systemDefault()
  var bestScore = 0

  private let engine = GameEngine()
  private var timerTask: Task<Void, Never>?
  private var feedbackTask: Task<Void, Never>?

  var timeFraction: Double {
    max(0, min(1, timeLeft / Self.gameDuration))
  }

  var isUrgent: Bool { timeLeft <= 10 && phase == .playing }

  // MARK: - Lifecycle

  func load() {
    guard phase == .loading else { return }
    do {
      countries = try CountryStore.load()
      phase = countries.isEmpty ? .loading : .ready
      if countries.isEmpty { loadError = "No countries found." }
    } catch {
      loadError = error.localizedDescription
    }
  }

  func start() {
    timerTask?.cancel()
    feedbackTask?.cancel()
    score = 0
    rounds = 0
    timeLeft = Self.gameDuration
    lastResult = nil
    question = engine.makeQuestion(from: countries)
    phase = .playing
    timerTask = Task { await runTimer() }
  }

  func playAgain() {
    start()
  }

  func stop() {
    timerTask?.cancel()
    feedbackTask?.cancel()
    timerTask = nil
    feedbackTask = nil
  }

  // MARK: - Answering

  /// Returns true if the pick was correct. Ignores taps while feedback is showing.
  @discardableResult
  func answer(_ country: Country) -> Bool {
    guard phase == .playing, let question, lastResult == nil else { return false }
    rounds += 1
    let correct = country == question.answer
    if correct {
      score += 1
      lastResult = .correct(country)
    } else {
      lastResult = .wrong(picked: country, correct: question.answer)
    }
    feedbackTask?.cancel()
    feedbackTask = Task { [correct] in
      try? await Task.sleep(for: .milliseconds(correct ? 450 : 650))
      guard !Task.isCancelled else { return }
      self.advance()
    }
    return correct
  }

  private func advance() {
    guard phase == .playing else { return }
    lastResult = nil
    question = engine.makeQuestion(from: countries, previousAnswer: question?.answer)
  }

  private func runTimer() async {
    while timeLeft > 0, !Task.isCancelled {
      try? await Task.sleep(for: .seconds(1))
      guard !Task.isCancelled else { return }
      timeLeft = max(0, timeLeft - 1)
    }
    guard !Task.isCancelled else { return }
    finish()
  }

  private func finish() {
    timerTask?.cancel()
    timerTask = nil
    if score > bestScore { bestScore = score }
    phase = .finished
  }
}
