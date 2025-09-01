//
//  CustomViewModifiers.swift
//  Sandbag
//
//  Created by Rickey Johnson on 9/1/25.
//

import Foundation
import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SandbagDesign.cardBackground)
            .cornerRadius(SandbagDesign.cornerRadiusM)
            .shadow(color: SandbagDesign.cardShadow, radius: 8, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let isDestructive: Bool
    
    init(isDestructive: Bool = false) {
        self.isDestructive = isDestructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SandbagDesign.paddingM)
            .background(
                RoundedRectangle(cornerRadius: SandbagDesign.cornerRadiusM)
                    .fill(isDestructive ? Color.red : SandbagDesign.accent)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundColor(SandbagDesign.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SandbagDesign.paddingM)
            .background(
                RoundedRectangle(cornerRadius: SandbagDesign.cornerRadiusM)
                    .stroke(SandbagDesign.accent, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: SandbagDesign.cornerRadiusM)
                            .fill(Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
