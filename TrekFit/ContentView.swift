//
//  ContentView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 29/04/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to TrekFit!")
                    .font(.largeTitle.bold())
                
                NavigationLink {
                    LandingView()
                } label: {
                    Text("Landing Page")
                        .font(.headline)
                        .frame(maxWidth: 100)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    ConnectWatchView()
                } label: {
                    Text("Connnect to Watch")
                        .font(.headline)
                        .frame(maxWidth: 100)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            }
            .padding()
            .navigationTitle("TrekFit")
        }
    }
}

#Preview {
    ContentView()
}
