//  AnswerButton.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// One of the 6 tappable answers. Narrow input: title + state, no ViewModel.
struct AnswerButton: View {
  let title: String
  let state: State
  let action: () -> Void

  enum State: Equatable {
    case idle
    case correct
    case wrong
    case dimmed
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, minHeight: 52)
        .contentShape(.rect)
    }
    .buttonStyle(.borderedProminent)
    .tint(tint)
    .disabled(state != .idle)
    .scaleEffect(state == .correct ? 1.04 : 1)
    .opacity(state == .dimmed ? 0.55 : 1)
  }

  private var tint: Color {
    switch state {
    case .idle: .accentColor
    case .correct: .green
    case .wrong: .red
    case .dimmed: .gray
    }
  }
}
