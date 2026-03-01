import SwiftUI

extension Color {
    // MARK: - Primary Colors
    /// Deep indigo/navy — the app's primary background tone
    static let suhoorIndigo = Color(red: 0.08, green: 0.07, blue: 0.20)
    /// Slightly lighter navy for cards and surfaces
    static let suhoorNavy = Color(red: 0.10, green: 0.10, blue: 0.25)
    
    // MARK: - Accent Colors
    /// Warm gold — primary accent, Ramadan-themed
    static let suhoorGold = Color(red: 0.85, green: 0.68, blue: 0.32)
    /// Softer amber for secondary highlights
    static let suhoorAmber = Color(red: 0.93, green: 0.78, blue: 0.45)
    
    // MARK: - Semantic Colors
    /// Primary text on dark backgrounds
    static let suhoorTextPrimary = Color.white.opacity(0.95)
    /// Secondary/muted text
    static let suhoorTextSecondary = Color.white.opacity(0.6)
    /// Surface color for cards
    static let suhoorSurface = Color.white.opacity(0.06)
    /// Subtle border/divider
    static let suhoorDivider = Color.white.opacity(0.08)
    
    // MARK: - Status Colors
    static let suhoorSuccess = Color(red: 0.30, green: 0.78, blue: 0.55)
    static let suhoorWarning = Color(red: 0.95, green: 0.70, blue: 0.25)
}
