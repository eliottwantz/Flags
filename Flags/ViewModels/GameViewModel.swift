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
/// Time is deadline-driven: `GameTimer` emits a typed event at a monotonic
/// deadline while the UI independently renders that deadline via `TimelineView`.
@Observable
@MainActor
final class GameViewModel {
  static let languageKey = "appLanguage"
  static let bestScoreKey = "bestScore"

  var phase: GamePhase = .loading
  var countries: [Country] = []
  var question: GameQuestion?
  var score = 0
  var rounds = 0
  var timerSession: GameTimer.Session?
  var lastResult: AnswerResult?
  var loadError: String?
  var language: AppLanguage {
    didSet { defaults.set(language.rawValue, forKey: Self.languageKey) }
  }
  var bestScore: Int {
    didSet { defaults.set(bestScore, forKey: Self.bestScoreKey) }
  }

  private let defaults: UserDefaults
  private let engine = GameEngine()
  private let timer = GameTimer()
  private var timerTask: Task<Void, Never>?
  private var feedbackTask: Task<Void, Never>?

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    if let raw = defaults.string(forKey: Self.languageKey),
      let stored = AppLanguage(rawValue: raw)
    {
      self.language = stored
    } else {
      self.language = .systemDefault()
    }
    self.bestScore = defaults.integer(forKey: Self.bestScoreKey)
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
    timerTask?.cancel()
    feedbackTask?.cancel()
    score = 0
    rounds = 0
    lastResult = nil
    question = engine.makeQuestion(from: countries)
    let session = timer.makeSession()
    timerSession = session
    phase = .playing

    timerTask = Task { @concurrent [weak self, timer, session] in
      do {
        let event = try await timer.event(for: session)
        await self?.handle(event)
      } catch is CancellationError {
        // Starting over or stopping the game cancels the scheduled event.
      } catch {
        assertionFailure("Unexpected game timer failure: \(error)")
      }
    }
  }

  func playAgain() {
    start()
  }

  func stop() {
    timerTask?.cancel()
    feedbackTask?.cancel()
    timerTask = nil
    feedbackTask = nil
    timerSession = nil
  }

  /// Reconciles delayed scheduling after the app returns to the foreground.
  func reconcileTimer() {
    guard let timerSession, timerSession.hasEnded() else { return }
    handle(.timerEnded(sessionID: timerSession.id))
  }

  func handle(_ event: GameEvent) {
    switch event {
    case .timerEnded(let sessionID):
      guard phase == .playing, timerSession?.id == sessionID else { return }
      finish()
    }
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
      try? await Task.sleep(for: .milliseconds(correct ? 350 : 1100))
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
    timerTask?.cancel()
    feedbackTask?.cancel()
    timerTask = nil
    feedbackTask = nil
    timerSession = nil
    if score > bestScore { bestScore = score }
    phase = .finished
  }
}
