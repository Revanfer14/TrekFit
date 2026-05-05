//
//  ManualInputCard.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI

struct ManualInputCard: View {
    @Binding var value: Double
    let presets: [Int]
    let unit: String
    let accent: Color
    
    @FocusState private var focused: Bool
    @State private var textValue: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Big number + unit
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Spacer()
                
                TextField("0", text: $textValue)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .font(.system(size: 56, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .tint(accent)
                    .onChange(of: textValue) { _, newVal in
                        let filtered = newVal.filter { $0.isNumber }
                        if filtered != newVal {
                            textValue = filtered
                        }
                        if let v = Double(filtered) {
                            value = v
                        }
                    }
                
                Text(unit)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                    .offset(y: 4)
            }
            
            // Presets
            HStack(spacing: 10) {
                ForEach(presets, id: \.self) { preset in
                    PresetPill(
                        value: preset,
                        isSelected: Int(value) == preset,
                        accent: accent
                    ) {
                        Haptics.impact(.soft)
                        value = Double(preset)
                        textValue = String(preset)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .onAppear {
            textValue = String(Int(value))
        }
        .onChange(of: value) { _, newVal in
            let intVal = Int(newVal)
            let newText = String(intVal)
            if textValue != newText {
                textValue = newText
            }
        }
    }
}

struct PresetPill: View {
    let value: Int
    let isSelected: Bool
    let accent: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(String(value))
                .font(.headline)
                .foregroundStyle(isSelected ? .white : accent)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    Capsule().fill(isSelected ? accent : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct InfoBanner: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(Color.black))
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }
}

struct ConfirmButton: View {
    let title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Color.orange))
        }
        .buttonStyle(.plain)
    }
}
