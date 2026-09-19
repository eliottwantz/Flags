//  Country.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT

import Foundation
import SwiftUI

/// UI language for country names + chrome. V1: explicit toggle, defaults to system.
enum AppLanguage: String, Sendable, CaseIterable, Identifiable {
  case english = "en"
  case french = "fr"

  var id: String { rawValue }

  var label: String {
    switch self {
    case .english: "English"
    case .french: "Français"
    }
  }

  static func systemDefault() -> AppLanguage {
    Locale.current.language.languageCode?.identifier == "fr" ? .french : .english
  }

  /// Locale driven into the environment so the String Catalog follows the in-app toggle.
  var locale: Locale { Locale(identifier: rawValue) }
}

/// One playable country. `Sendable` for Swift 6 strict concurrency.
struct Country: Codable, Sendable, Hashable, Identifiable {
  let code: String
  let code3: String?
  let name_en: String
  let name_fr: String
  let emoji: String?

  var id: String { code }

  /// Asset catalog name: lowercase alpha-2, e.g. "fr".
  var assetName: String { code.lowercased() }

  func displayName(for language: AppLanguage) -> String {
    switch language {
    case .english: name_en
    case .french: name_fr
    }
  }
}

struct CountriesFile: Codable, Sendable {
  let count: Int
  let countries: [Country]
}

enum CountryStoreError: Error {
  case missingResource
}

/// Loads the bundled countries.json. Pure + Sendable, safe to call from anywhere.
struct CountryStore: Sendable {
  static func load(bundle: Bundle = .main) throws -> [Country] {
    guard let url = bundle.url(forResource: "countries", withExtension: "json") else {
      throw CountryStoreError.missingResource
    }
    let data = try Data(contentsOf: url)
    let file = try JSONDecoder().decode(CountriesFile.self, from: data)
    // ISO-only (skips the 4 disputed entities with empty codes), sorted for stability.
    return file.countries
      .filter { !$0.code.isEmpty }
      .sorted { $0.name_en < $1.name_en }
  }
}
