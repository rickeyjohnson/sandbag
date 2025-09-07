//
//  SandbagDesign.swift
//  Sandbag
//
//  Created by Rickey Johnson on 9/1/25.
//

import Foundation
import SwiftUI

struct AppleDesign {
    // Colors - Using system colors for true iOS feel
    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
    static let accent = Color.accentColor
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let separator = Color(.separator)
    
    // Spacing - Apple's standard spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    
    // Corner Radius
    static let cornerRadius: CGFloat = 10
    static let buttonRadius: CGFloat = 8
}
