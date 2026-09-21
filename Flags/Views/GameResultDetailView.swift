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
      GameResult.where {
        $0.score.gt(result.score)
          || ($0.score.eq(result.score) && $0.rounds.lt(result.rounds))
          || ($0.score.eq(result.score) && $0.rounds.eq(result.rounds) && $0.playedAt.gt(result.playedAt))
      }.count()
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

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 0) {
        switch rank {
        case 1, 2, 3:
          Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
            .font(.system(size: 64, weight: .black, design: .rounded))
        default:
          EmptyView()
        }
        MedalScoreText(score: score, rank: rank)
      }
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

/// Score rendered with a realistic brushed-metal shader for medal ranks,
/// falling back to plain text otherwise.
struct MedalScoreText: View {
  let score: Int
  let rank: Int?

  var body: some View {
    switch rank {
    case 1, 2, 3:
      GeometryReader { proxy in
        MedalShaderLabel(
          score: score,
          medal: .init(rank: rank),
          width: Float(proxy.size.width),
          height: Float(proxy.size.height)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(height: 84)
    default:
      Text("\(score) pts")
        .font(.system(size: 64, weight: .black, design: .rounded))
        .monospacedDigit()
    }
  }
}

struct MedalShaderLabel: View {
  let score: Int
  let medal: MedalType
  let width: Float
  let height: Float

  enum MedalType {
    case gold, silver, bronze

    init(rank: Int?) {
      switch rank {
      case 1: self = .gold
      case 2: self = .silver
      default: self = .bronze
      }
    }
  }

  var body: some View {
    switch medal {
    case .gold:
      baseText
        .foregroundStyle(.white)
        .colorEffect(ShaderLibrary.medalGold(.float(width), .float(height)))
    case .silver:
      baseText
        .foregroundStyle(.white)
        .colorEffect(ShaderLibrary.medalSilver(.float(width), .float(height)))
    case .bronze:
      baseText
        .foregroundStyle(.white)
        .colorEffect(ShaderLibrary.medalBronze(.float(width), .float(height)))
    }
  }

  private var baseText: some View {
    Text("\(score) pts")
      .font(.system(size: 64, weight: .black, design: .rounded))
      .monospacedDigit()
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

#Preview(
  "Tied score gets silver",
  traits: .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed {
        GameResult(
          id: UUID(0),
          playedAt: Date().addingTimeInterval(-7200),
          score: 12,
          rounds: 15,
          durationSeconds: 60
        )
        GameResult(
          id: UUID(1),
          playedAt: Date(),
          score: 12,
          rounds: 14,
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
        playedAt: Date().addingTimeInterval(-7200),
        score: 12,
        rounds: 15,
        durationSeconds: 60
      )
    )
  }
}

#Preview(
  "Better precision wins tie",
  traits: .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed {
        GameResult(
          id: UUID(0),
          playedAt: Date().addingTimeInterval(-7200),
          score: 12,
          rounds: 13,
          durationSeconds: 60
        )
        GameResult(
          id: UUID(1),
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
        playedAt: Date().addingTimeInterval(-7200),
        score: 12,
        rounds: 13,
        durationSeconds: 60
      )
    )
  }
}

#Preview(
  "Bronze medal",
  traits: .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed {
        GameResult(
          id: UUID(0),
          playedAt: Date().addingTimeInterval(-7200),
          score: 15,
          rounds: 18,
          durationSeconds: 60
        )
        GameResult(
          id: UUID(1),
          playedAt: Date().addingTimeInterval(-3600),
          score: 12,
          rounds: 15,
          durationSeconds: 60
        )
        GameResult(
          id: UUID(2),
          playedAt: Date(),
          score: 9,
          rounds: 12,
          durationSeconds: 60
        )
      }
    }
  }
) {
  NavigationStack {
    GameResultDetailView(
      result: GameResult(
        id: UUID(2),
        playedAt: Date(),
        score: 9,
        rounds: 12,
        durationSeconds: 60
      )
    )
  }
}
