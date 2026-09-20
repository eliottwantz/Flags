//  GameResult.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation
import SQLiteData

/// One finished 1-minute game. Synced via CloudKit so history is shared
/// across the user's iOS and macOS devices.
@Table
struct GameResult: Identifiable, Hashable {
  let id: UUID
  var playedAt = Date()
  var score = 0
  var rounds = 0
  var durationSeconds = 60
}

extension GameResult {
  var accuracy: Double {
    guard rounds > 0 else { return 0 }
    return Double(score) / Double(rounds)
  }
}
