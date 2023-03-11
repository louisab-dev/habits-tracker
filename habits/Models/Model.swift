//
//  Model.swift
//  habits
//
//  Created by Louis AB on 09/03/2023.
//

import SwiftUI

class Model: ObservableObject {
    // Tab Bar
    @Published var showTab: Bool = true

    // Navigation Bar
    @Published var showNav: Bool = true

    @Published var loggedIn: Bool = false

    @Published var showSafari: Bool = false
}

struct TabItem: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var selection: Tab
}

var tabItems = [
    TabItem(name: "Home", icon: "house", color: .purple, selection: .home),
    TabItem(name: "Streaks", icon: "flame", color: .purple, selection: .streaks),
    TabItem(name: "Settings", icon: "gear", color: .purple, selection: .settings)
]

enum Tab: String {
    case home
    case streaks
    case settings
}
