//  FlagCardView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Center flag card. Narrow input: only what it renders (asset name + feedback tint).
struct FlagCardView: View {
  let assetName: String
  let feedback: AnswerResult?
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var glow: Color? {
    switch feedback {
    case .correct: .green
    case .wrong: .red
    case nil: nil
    }
  }

  var body: some View {
    Image(assetName)
      .resizable()
      .scaledToFit()
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(.secondary.opacity(0.25), lineWidth: 1)
      }
      .shadow(color: (glow ?? .black).opacity(glow == nil ? 0.2 : 0.45), radius: glow == nil ? 12 : 22, y: 8)
      .scaleEffect(feedback == nil ? 1 : 1.03)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7), value: feedback)
      .accessibilityLabel(Text("Flag to guess"))
  }
}

#Preview("mk") {
  VStack {
    FlagCardView(assetName: "mk", feedback: nil)
  }
  .padding(60)
}
