//  GameResultDetailView.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Dependencies
import SQLiteData
import SwiftUI

/// Dedicated screen showing the stats of a single finished game.
struct GameResultDetailView: View {
  let result: GameResult

  @FetchOne var higherScoreCount = 0

  init(result: GameResult) {
    self.result = result
    _higherScoreCount = FetchOne(
      wrappedValue: 0,
      GameResult.where { $0.score.gt(result.score) }.count()
    )
  }

  private var rank: Int {
    higherScoreCount + 1
  }

  var body: some View {
    List {
      GameResultScoreHeader(score: result.score, rounds: result.rounds, rank: rank)
      GameResultStatsSection(result: result)
    }
    .navigationTitle(result.playedAt.formatted(date: .abbreviated, time: .shortened))
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct GameResultScoreHeader: View {
  let score: Int
  let rounds: Int
  let rank: Int?

  init(score: Int, rounds: Int, rank: Int? = nil) {
    self.score = score
    self.rounds = rounds
    self.rank = rank
  }

  private var scoreColor: Color {
    switch rank {
    case 1: .medalGold
    case 2: .medalSilver
    case 3: .medalBronze
    default: .primary
    }
  }

  var body: some View {
    VStack(spacing: 4) {
      Text("\(score) pts")
        .font(.system(size: 64, weight: .black, design: .rounded))
        .foregroundStyle(scoreColor)
        .monospacedDigit()
      Text("\(rounds) flags seen")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .listRowBackground(Color.clear)
    .listRowSeparator(.hidden)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Scored \(score) out of \(rounds)")
  }
}

struct GameResultStatsSection: View {
  let result: GameResult

  var body: some View {
    Section("Game stats") {
      LabeledContent("Date") {
        Text(result.playedAt, format: .dateTime.day().month().year())
      }
      LabeledContent("Time") {
        Text(result.playedAt, format: .dateTime.hour().minute())
      }
      LabeledContent("Score") {
        Text("\(result.score) pts")
          .monospacedDigit()
      }
      LabeledContent("Rounds") {
        Text("\(result.rounds) seen")
          .monospacedDigit()
      }
      LabeledContent("Accuracy") {
        Text(result.accuracy, format: .percent.precision(.fractionLength(0)))
          .monospacedDigit()
      }
      LabeledContent("Duration") {
        Text("\(result.durationSeconds) sec")
          .monospacedDigit()
      }
    }
  }
}

#Preview(
  "Game result detail",
  traits: .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed {
        GameResult(
          id: UUID(0),
          playedAt: Date(),
          score: 12,
          rounds: 15,
          durationSeconds: 60
        )
      }
    }
  }
) {
  NavigationStack {
    GameResultDetailView(
      result: GameResult(
        id: UUID(0),
        playedAt: Date(),
        score: 12,
        rounds: 15,
        durationSeconds: 60
      )
    )
  }
}
