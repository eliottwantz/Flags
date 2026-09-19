//
//  ContentView.swift
//  Flags
//
//  Created by Eliott Wantz on 19/09/2026.
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image("bd")
        .resizable()
        .scaledToFit()
        .imageScale(.large)
      Image("cc")
        .resizable()
        .scaledToFit()
        .imageScale(.large)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
