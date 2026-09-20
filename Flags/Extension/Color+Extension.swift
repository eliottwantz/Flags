//
//  Color+Extension.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT
//

import SwiftUI

#if canImport(UIKit)
  import UIKit
  typealias PlatformColor = UIColor
#elseif canImport(AppKit)
  import AppKit
  typealias PlatformColor = NSColor
#endif

extension Color {
  /// Gold for rank 1 (#D4AF37).
  static let medalGold = Color(red: 0.831, green: 0.686, blue: 0.216)
  /// Silver for rank 2 (#8A8D93, darkened for contrast in light mode).
  static let medalSilver = Color(red: 0.541, green: 0.553, blue: 0.576)
  /// Bronze for rank 3 (#CD7F32).
  static let medalBronze = Color(red: 0.804, green: 0.498, blue: 0.196)

  /// Returns black or white, whichever contrasts better with this color.
  func contrastingText() -> Color {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    #if canImport(UIKit)
      PlatformColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
    #elseif canImport(AppKit)
      // NSColor.getRed(...) throws if not in an RGB space — convert first.
      guard let rgb = PlatformColor(self).usingColorSpace(.sRGB) else {
        return .white
      }
      rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
    #endif

    let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return luminance > 0.6 ? .black : .white
  }
}
