//  EqualHeightAdaptiveGrid.swift
//  Flags
//
//  Created by Eliott Wantz on 20/09/2026.
//  SPDX-License-Identifier: MIT

import SwiftUI

/// Adaptive grid where every cell shares the height of the tallest cell.
///
/// `LazyVGrid` equalizes heights within a row only, so a long title in one
/// row leaves other rows shorter. This layout measures all subviews at the
/// final cell width and uses the max height for every cell. If all titles
/// fit on 1 line the grid is 1-line tall, if one needs 2-3 lines they all do.
struct EqualHeightAdaptiveGrid: Layout {
  var minimumWidth: CGFloat = 160
  var columnSpacing: CGFloat = 10
  var rowSpacing: CGFloat = 10

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    guard !subviews.isEmpty else { return .zero }
    guard let availableWidth = proposal.width, availableWidth > 0 else {
      // No width proposal: fall back to single-column intrinsic sizing.
      let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
      let width = sizes.map(\.width).max() ?? 0
      let height = sizes.reduce(0) { $0 + $1.height } + rowSpacing * CGFloat(max(0, subviews.count - 1))
      return CGSize(width: width, height: height)
    }
    let columns = columnCount(for: availableWidth)
    let cellWidth = self.cellWidth(for: availableWidth, columns: columns)
    let maxHeight = self.maxHeight(for: subviews, cellWidth: cellWidth)
    let rows = (subviews.count + columns - 1) / columns
    let totalHeight = CGFloat(rows) * maxHeight + CGFloat(max(0, rows - 1)) * rowSpacing
    return CGSize(width: availableWidth, height: totalHeight)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    guard !subviews.isEmpty, bounds.width > 0 else { return }
    let columns = columnCount(for: bounds.width)
    let cellWidth = self.cellWidth(for: bounds.width, columns: columns)
    let maxHeight = self.maxHeight(for: subviews, cellWidth: cellWidth)
    for (index, subview) in subviews.enumerated() {
      let row = index / columns
      let column = index % columns
      let x = bounds.minX + CGFloat(column) * (cellWidth + columnSpacing)
      let y = bounds.minY + CGFloat(row) * (maxHeight + rowSpacing)
      subview.place(
        at: CGPoint(x: x, y: y),
        proposal: ProposedViewSize(width: cellWidth, height: maxHeight)
      )
    }
  }

  private func columnCount(for availableWidth: CGFloat) -> Int {
    max(1, Int((availableWidth + columnSpacing) / (minimumWidth + columnSpacing)))
  }

  private func cellWidth(for availableWidth: CGFloat, columns: Int) -> CGFloat {
    (availableWidth - CGFloat(columns - 1) * columnSpacing) / CGFloat(columns)
  }

  private func maxHeight(for subviews: Subviews, cellWidth: CGFloat) -> CGFloat {
    subviews
      .map { $0.sizeThatFits(ProposedViewSize(width: cellWidth, height: nil)).height }
      .max() ?? 0
  }
}
