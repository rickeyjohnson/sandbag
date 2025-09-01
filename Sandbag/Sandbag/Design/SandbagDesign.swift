//
//  SandbagDesign.swift
//  Sandbag
//
//  Created by Rickey Johnson on 9/1/25.
//

import Foundation
import SwiftUI

struct SandbagDesign {
    // Colors
    static let primaryBlue = Color.blue
    static let primaryRed = Color.red
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let accent = Color.accentColor
    
    // Spacing
    static let paddingXS: CGFloat = 4
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let paddingXL: CGFloat = 32
    
    // Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    
    // Shadows
    static let cardShadow = Color.black.opacity(0.1)
}
