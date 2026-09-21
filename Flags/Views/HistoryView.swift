//  HistoryView.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Dependencies
import Foundation
import SQLiteData
import SwiftUI

/// Dedicated history screen, synced via CloudKit so iOS and macOS show the same list.
struct HistoryView: View {
  @FetchAll(GameResult.order { $0.playedAt.desc() }.limit(20)) var recentResults
  @FetchAll(GameResult.order { ($0.score.desc(), $0.rounds, $0.playedAt.desc()) }.limit(5)) var bestResults
  @FetchOne(GameResult.count()) var totalCount = 0

  var body: some View {
    Group {
      if recentResults.isEmpty && bestResults.isEmpty {
        ContentUnavailableView(
          "No games yet",
          systemImage: "clock",
          description: Text("Play your first minute!")
        )
      } else {
        List {
          BestGamesSection(results: bestResults)
          RecentGamesSection(results: recentResults)
        }
      }
    }
    .navigationTitle("History (\(totalCount) total)")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: GameResult.self) { result in
      GameResultDetailView(result: result)
    }
  }
}

struct RecentGamesSection: View {
  let results: [GameResult]

  var body: some View {
    Section("Recent games") {
      ForEach(results) { result in
        NavigationLink(value: result) {
          GameResultRow(result: result)
        }
      }
    }
  }
}

struct BestGamesSection: View {
  let results: [GameResult]

  var body: some View {
    Section("Best games") {
      ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
        NavigationLink(value: result) {
          GameResultRankRow(rank: index + 1, result: result)
        }
      }
    }
  }
}

struct GameResultRow: View {
  let result: GameResult

  var body: some View {
    VStack {
      HStack {
        Text(result.playedAt, style: .date)
          .font(.subheadline)
        Text(result.playedAt, style: .time)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Spacer()
        Text("\(result.score) pts")
          .font(.subheadline.bold())
          .monospacedDigit()
        Text("· \(result.rounds) seen")
          .font(.caption)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "Scored \(result.score) out of \(result.rounds) on \(result.playedAt.formatted())"
    )
  }
}

struct GameResultRankRow: View {
  let rank: Int
  let result: GameResult

  private var rankColor: Color {
    switch rank {
    case 1: .medalGold
    case 2: .medalSilver
    case 3: .medalBronze
    default: .secondary
    }
  }

  var body: some View {
    VStack {
      HStack {
        Text("\(rank)")
          .font(.subheadline.bold())
          .foregroundStyle(rankColor)
          .monospacedDigit()
          .frame(minWidth: 24, alignment: .leading)
        Text(result.playedAt, style: .date)
          .font(.subheadline)
        Spacer()
        Text("\(result.score) pts")
          .font(.subheadline.bold())
          .monospacedDigit()
        Text("· \(result.rounds) seen")
          .font(.caption)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "Rank \(rank), scored \(result.score) out of \(result.rounds) on \(result.playedAt.formatted())"
    )
  }
}

#Preview(
  "History",
  traits: .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed {
        GameResult(
          id: UUID(0),
          playedAt: Date().addingTimeInterval(-3600),
          score: 12,
          rounds: 15,
          durationSeconds: 60
        )
        GameResult(
          id: UUID(1),
          playedAt: Date().addingTimeInterval(-7200),
          score: 7,
          rounds: 10,
          durationSeconds: 60
        )
      }
    }
  }
) {
  NavigationStack {
    HistoryView()
  }
}

#Preview(
  "No history",
  traits: .dependencies {
    try $0.bootstrapDatabase()
  }
) {
  NavigationStack {
    HistoryView()
  }
}
