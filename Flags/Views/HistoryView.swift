//  HistoryView.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import Dependencies
import Foundation
import SQLiteData
import SwiftUI

/// Recent game history, synced via CloudKit so iOS and macOS show the same list.
struct HistoryView: View {
  @FetchAll(GameResult.order { $0.playedAt.desc() }.limit(20)) var results
  @FetchOne(GameResult.count()) var totalCount = 0

  var body: some View {
    VStack {
      if results.isEmpty {
        Text("No games yet — play your first minute!")
          .font(.headline.weight(.regular))
      } else {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("Recent games")
              .font(.headline)
            Spacer()
            Text("\(totalCount) total")
              .font(.caption)
              .foregroundStyle(.secondary)
              .monospacedDigit()
          }
          ForEach(results) { result in
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
              "Scored \(result.score) out of \(result.rounds) on \(result.playedAt.formatted())"
            )
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding(.vertical)
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
  HistoryView()
    .padding()
}

#Preview(
  "No history",
  traits: .dependencies {
    try $0.bootstrapDatabase()
  }
) {
  HistoryView()
    .padding()
}
