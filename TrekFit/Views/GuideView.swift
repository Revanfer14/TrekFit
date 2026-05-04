//
//  GuideView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 01/05/26.
//

import SwiftUI

struct GuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var hrMonitor: HeartRateMonitor
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Custom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                
                Spacer()
                
                Text("Guide")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.red)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    Text("\(Int(hrMonitor.currentHR ?? 0))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chester Step Test")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Follow the rhythm to assess your aerobic capacity")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 24)
                    
                    // MARK: - GIF Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(height: 220)
                        
                        Text("GIF")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    // Step Info
                    HStack(spacing: 12) {
                        Image(systemName: "figure.step.training")
                            .font(.system(size: 20))
                        Text("Step up and down in 4 counts.")
                            .font(.system(size: 16))
                    }
                    .padding(.vertical, 8)
                    .foregroundColor(Color.black)
                    
                    // MARK: - Posture and Setup
                    Text("Posture and Setup")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        InstructionCard(
                            icon: "figure.walk",
                            title: "Maintain Upright Torso",
                            description: "Avoid leaning forward excessively. Keep your gaze straight forward"
                        )
                        
                        InstructionCard(
                            icon: "figure.mixed.cardio",
                            title: "Full Foot Contact",
                            description: "Ensure your entire foot is on the step to maintain balance and safety."
                        )
                        
                        InstructionCard(
                            icon: "speaker.wave.2.fill",
                            title: "Volume Up",
                            description: "Ensure your volume is up. You must keep time with the metronome."
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // MARK: - Bottom Button (Dynamic State)
            VStack {
                NavigationLink(destination: CircleLoadingView(hrMonitor: hrMonitor)) {
                    HStack(spacing: 12) {
                        if !hrMonitor.isReceivingData {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Mendeteksi Watch...")
                                .font(.system(size: 18, weight: .semibold))
                        } else {
                            Text("Start Test")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange.opacity(hrMonitor.isReceivingData ? 1.0 : 0.6))
                    .cornerRadius(30)
                }
                .disabled(!hrMonitor.isReceivingData)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .padding(.top, 16)
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    GuideView(hrMonitor: HeartRateMonitor())
}
