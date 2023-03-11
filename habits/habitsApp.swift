//
//  habitsApp.swift
//  habits
//
//  Created by Louis AB on 09/03/2023.
//

import Supabase
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var client: SupabaseClient!

    internal func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions:
                              [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Authorization granted.")
            } else {
                print("Authorization denied.")
            }
        }

        // Schedule recurring notifications at 9am and 9pm
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to complete your habits today!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        dateComponents.hour = 21
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request1 = UNNotificationRequest(identifier: "morning_notification", content: content, trigger: trigger1)
        let request2 = UNNotificationRequest(identifier: "evening_notification", content: content, trigger: trigger2)

        UNUserNotificationCenter.current().add(request1)
        UNUserNotificationCenter.current().add(request2)

        // Initialize Supabase client
        client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!, supabaseKey: Constants.supabaseKey)
        print("initialized supabase client")

        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        print("url")
        return true
    }
}

@main
struct habit_trackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var model = Model()
    var userHabitsContentModel = UserHabitsContentModel()
    var userSettingsContentModel = UserSettingsContentModel()
    var userFriendsContentModel = UserFriendsContentModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(model)
                .environmentObject(userHabitsContentModel)
                .environmentObject(userSettingsContentModel)
                .environmentObject(userFriendsContentModel)
                .onOpenURL(perform: handleURL)
        }
    }

    func handleURL(_ url: URL) {
        if url.host == "auth-callback" {
            Task {
                do {
                    _ = try await delegate.client.auth.session(from: url)
                    model.loggedIn = true
                    print("### Successful oAuth")
                } catch {
                    print("### oAuthCallback error: \(error)")
                }
            }
        }
    }
}
