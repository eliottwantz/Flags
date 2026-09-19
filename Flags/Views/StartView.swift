//  StartView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Pre-game screen: title, rules, language toggle, best score.
struct StartView: View {
  let best: Int
  let language: AppLanguage
  let onLanguage: (AppLanguage) -> Void
  let onPlay: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Spacer()
      Text("🏳️")
        .font(.system(size: 64))
        .accessibilityHidden(true)
      Text(language == .french ? "Devine les drapeaux" : "Guess the Flags")
        .font(.largeTitle.bold())
      Text(language == .french
        ? "Devine un maximum de drapeaux en 1 minute. 6 choix par drapeau."
        : "Guess as many flags as you can in 1 minute. 6 choices per flag.")
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Picker(language == .french ? "Langue" : "Language", selection: Binding(
        get: { language },
        set: { onLanguage($0) }
      )) {
        ForEach(AppLanguage.allCases) { lang in
          Text(lang == .french ? "Français" : "English").tag(lang)
        }
      }
      .pickerStyle(.segmented)
      .frame(maxWidth: 240)

      Button(language == .french ? "Jouer" : "Play", systemImage: "play.fill", action: onPlay)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .font(.title3.bold())

      if best > 0 {
        Text(language == .french ? "Record : \(best)" : "Best: \(best)")
          .font(.headline)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      Spacer()
    }
    .padding()
  }
}
