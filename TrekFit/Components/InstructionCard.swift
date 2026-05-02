//
//  InstructionCard.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 02/05/26.
//

import SwiftUI

struct InstructionCard: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 32)
                .padding(.top, 2) // Sedikit penyesuaian agar sejajar dengan judul
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.primary.opacity(0.8))
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.6))
        .cornerRadius(12)
    }
}
