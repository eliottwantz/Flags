//  StartView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import Dependencies
import SQLiteData
import SwiftUI

/// Pre-game screen: title, rules, language toggle, best score.
struct StartView: View {
  let best: Int?
  let language: AppLanguage
  let onLanguage: (AppLanguage) -> Void
  let onPlay: () -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        Text(verbatim: "🏳️")
          .font(.system(size: 64))
          .accessibilityHidden(true)
        Text("Guess the Flags")
          .font(.largeTitle.bold())
        Text("Guess as many flags as you can in 1 minute. 6 choices per flag.")
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        Picker(
          "Language",
          selection: Binding(
            get: { language },
            set: { onLanguage($0) }
          )
        ) {
          ForEach(AppLanguage.allCases) { lang in
            Text(lang.label).tag(lang)
          }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 240)

        Button("Play", systemImage: "play.fill", action: onPlay)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .font(.title3.bold())
          .foregroundStyle(.accent.contrastingText())

        if let best, best > 0 {
          Text("Best: \(best)")
            .font(.headline)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink {
            HistoryView()
          } label: {
            Label("Recent games", systemImage: "clock")
          }
        }
      }
    }
  }
}

#Preview(
  "First launch",
  traits: .dependencies {
    try $0.bootstrapDatabase()
  }
) {
  StartView(best: nil, language: .english, onLanguage: { _ in }, onPlay: {})
}

#Preview(
  "Returning player",
  traits: .dependencies {
    try $0.bootstrapDatabase()
  }
) {
  StartView(best: 13, language: .french, onLanguage: { _ in }, onPlay: {})
}
