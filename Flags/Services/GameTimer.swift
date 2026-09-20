//  GameTimer.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation

enum GameEvent: Sendable, Equatable {
  case timerEnded(sessionID: UUID)
}

/// Schedules a single game-expiration event against a monotonic clock.
struct GameTimer: Sendable {
  static let gameDuration: TimeInterval = 60
  static let urgentThreshold: TimeInterval = 10

  private let clock = ContinuousClock()

  func makeSession(duration: TimeInterval = Self.gameDuration) -> Session {
    let now = clock.now

    return Session(
      id: UUID(),
      deadline: now.advanced(by: .seconds(duration)),
      displayDeadline: .now.addingTimeInterval(duration),
      duration: duration
    )
  }

  @concurrent
  func event(for session: Session) async throws -> GameEvent {
    try await clock.sleep(until: session.deadline)
    try Task.checkCancellation()
    return .timerEnded(sessionID: session.id)
  }
}

extension GameTimer {
  struct Session: Sendable, Equatable, Identifiable {
    let id: UUID
    let deadline: ContinuousClock.Instant
    let displayDeadline: Date
    let duration: TimeInterval

    func snapshot(at now: Date = .now) -> Snapshot {
      let remaining = max(0, min(duration, displayDeadline.timeIntervalSince(now)))

      return Snapshot(
        remaining: remaining,
        total: duration,
        seconds: max(0, Int(ceil(remaining))),
        isUrgent: remaining <= GameTimer.urgentThreshold
      )
    }

    func hasEnded(at now: ContinuousClock.Instant = ContinuousClock().now) -> Bool {
      now >= deadline
    }
  }

  struct Snapshot: Sendable, Equatable {
    let remaining: TimeInterval
    let total: TimeInterval
    let seconds: Int
    let isUrgent: Bool
  }
}
