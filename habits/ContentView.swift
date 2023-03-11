//
//  ContentView.swift
//  habits
//
//  Created by Louis AB on 09/03/2023.
//

import Supabase
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model
    @AppStorage("selectedTab") var selectedTab: Tab = .home

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    var body: some View {
        if !model.loggedIn {
            LoginView()
        } else {
            ZStack {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .streaks:
                        StreaksView()
                    case .settings:
                        SettingsView()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {}.frame(height: 44)
                }

                TabBar()
            }
            .dynamicTypeSize(.large ... .xxLarge)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Model())
    }
}
