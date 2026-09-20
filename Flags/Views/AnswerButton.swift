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
        .lineLimit(3)
        .minimumScaleFactor(0.8)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, minHeight: 22, maxHeight: .infinity)
        .background(.brown)
        .padding()
        .clipShape(ConcentricRectangle(corners: 12))
        .clipped()
        .background(tint, in: ConcentricRectangle(corners: 12))
        .foregroundStyle(tint.contrastingText())
    }
    // Custom style (instead of .borderedProminent/.plain) so .disabled
    // blocks interaction without forcing the system gray disabled tint
    // or dimming the label. Correct/wrong keep their green/red colors.
    .buttonStyle(AnswerButtonStyle())
    .disabled(state != .idle)
    .opacity(state == .dimmed ? 0.55 : 1)
    .overlay {
      ConcentricRectangle(corners: 12)
        .stroke(Color.secondary.opacity(0.4), lineWidth: state == .idle ? 2 : 0)
    }
  }

  private var tint: Color {
    switch state {
    case .idle:
      #if os(iOS)
        Color(.systemBackground)
      #else
        Color(NSColor.windowBackgroundColor)
      #endif

    case .correct: .green
    case .wrong: .red
    case .dimmed: .gray
    }
  }
}

/// Plain capsule style that preserves its colors when disabled.
/// System styles (.borderedProminent/.plain) gray/dim disabled buttons,
/// which hides the correct/wrong feedback. Interaction is still blocked
/// by the .disabled modifier on AnswerButton.
private struct AnswerButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.8 : 1)
  }
}

#Preview("4 states") {
  VStack(spacing: 10) {
    AnswerButton(title: "France", state: .idle, action: {})
    AnswerButton(title: "France", state: .correct, action: {})
    AnswerButton(title: "France", state: .wrong, action: {})
    AnswerButton(title: "France", state: .dimmed, action: {})
  }
  .padding()
}

#Preview("Long") {
  EqualHeightAdaptiveGrid(minimumWidth: 160, columnSpacing: 10, rowSpacing: 10) {
    AnswerButton(title: "Sainte-Hélène, Ascension et Tristan da Cunha", state: .idle, action: {})
    AnswerButton(title: "France", state: .idle, action: {})
    AnswerButton(title: "France", state: .correct, action: {})
    AnswerButton(title: "Sainte-Hélène, Ascension et Tristan da Cunha", state: .idle, action: {})
    AnswerButton(title: "France", state: .wrong, action: {})
    AnswerButton(title: "France", state: .dimmed, action: {})
  }
  .padding()
}
