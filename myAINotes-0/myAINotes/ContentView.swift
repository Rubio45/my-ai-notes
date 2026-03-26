//
//  ContentView.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NotesListView()
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }

            AIChatView()
                .tabItem {
                    Label("Chat IA", systemImage: "bubble.left.and.bubble.right")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppContainer.preview)
}
