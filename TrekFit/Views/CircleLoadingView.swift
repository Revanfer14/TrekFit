//
//  CircleLoadingView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 02/05/26.
//

import SwiftUI

struct CircleLoadingView: View {
    @State private var count = 4
    @State private var goNext = false
    
    var hrMonitor: HeartRateMonitor
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(Color(.black))
                .shadow(radius: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .onAppear {
            startCountdown()
        }
        .navigationDestination(isPresented: $goNext) {
            ChesterTestView(hrMonitor: hrMonitor)
        }
    }
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if count > 1 {
                count -= 1
                playSound("BeepSound")
            } else {
                timer.invalidate()
                goNext = true
            }
        }
    }
}

#Preview {
    CircleLoadingView(hrMonitor: HeartRateMonitor())
}
