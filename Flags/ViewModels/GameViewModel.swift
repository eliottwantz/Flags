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
///
/// Time is deadline-driven: `start()` sets `endDate`, the UI derives
/// remaining time from `endDate` via a `TimelineView`, and a single
/// task fires `finish()` at the deadline. No per-second `Task.sleep` tick.
@Observable
@MainActor
final class GameViewModel {
  static let gameDuration: TimeInterval = 60
  static let urgentThreshold: TimeInterval = 10

  var phase: GamePhase = .loading
  var countries: [Country] = []
  var question: GameQuestion?
  var score = 0
  var rounds = 0
  var endDate: Date?
  var lastResult: AnswerResult?
  var loadError: String?
  var language: AppLanguage = .systemDefault()
  var bestScore = 0

  private let engine = GameEngine()
  private var finishTask: Task<Void, Never>?
  private var feedbackTask: Task<Void, Never>?

  // MARK: - Deadline-derived state

  /// Remaining seconds at `now`, clamped to [0, gameDuration].
  func timeLeft(at now: Date = .now) -> Double {
    guard let endDate else { return Self.gameDuration }
    return max(0, min(Self.gameDuration, endDate.timeIntervalSince(now)))
  }

  func secondsLeft(at now: Date = .now) -> Int {
    max(0, Int(ceil(timeLeft(at: now))))
  }

  func timeFraction(at now: Date = .now) -> Double {
    timeLeft(at: now) / Self.gameDuration
  }

  func isUrgent(at now: Date = .now) -> Bool {
    phase == .playing && timeLeft(at: now) <= Self.urgentThreshold
  }

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
    finishTask?.cancel()
    feedbackTask?.cancel()
    score = 0
    rounds = 0
    lastResult = nil
    question = engine.makeQuestion(from: countries)
    let deadline = Date.now.addingTimeInterval(Self.gameDuration)
    endDate = deadline
    phase = .playing
    finishTask = Task { @MainActor [deadline] in
      let interval = deadline.timeIntervalSinceNow
      if interval > 0 {
        try? await Task.sleep(for: .seconds(interval))
      }
      guard !Task.isCancelled else { return }
      self.finish()
    }
  }

  func playAgain() {
    start()
  }

  func stop() {
    finishTask?.cancel()
    feedbackTask?.cancel()
    finishTask = nil
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

  private func finish() {
    finishTask?.cancel()
    finishTask = nil
    if score > bestScore { bestScore = score }
    phase = .finished
  }
}
