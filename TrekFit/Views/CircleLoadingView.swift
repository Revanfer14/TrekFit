//
//  CircleLoadingView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 02/05/26.
//

import SwiftUI

struct CircleLoadingView: View {
    @State private var count = 3
    @State private var goNext = false
    
    var hrMonitor: HeartRateMonitor
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 250, height: 250)
                
                Text("\(count)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
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
