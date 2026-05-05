//
//  MeasureWithCameraCard.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI

struct MeasureWithCameraCard: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.systemGray5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Measure with Camera")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Point your camera at the step to auto-detect its height")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}
