//
//  CustomViewModifiers.swift
//  Sandbag
//
//  Created by Rickey Johnson on 9/1/25.
//

import Foundation
import SwiftUI

struct ApplePrimaryButtonStyle: ButtonStyle {
    let isDestructive: Bool
    
    init(isDestructive: Bool = false) {
        self.isDestructive = isDestructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: AppleDesign.buttonRadius)
                    .fill(isDestructive ? Color.red : AppleDesign.accent)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppleSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundColor(AppleDesign.accent)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: AppleDesign.buttonRadius)
                    .fill(AppleDesign.accent.opacity(0.1))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
