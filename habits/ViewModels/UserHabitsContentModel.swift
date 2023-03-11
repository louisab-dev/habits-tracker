//
//  UserHabitsContentModel.swift
//  habits
//
//  Created by Louis AB on 09/03/2023.
//

import Foundation
import Supabase

class UserHabitsContentModel: ObservableObject {
    @Published var userHabits = [Habits]()
    @Published var loadingUserHabits = false

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @MainActor
    func updateUserHabits() async {
        loadingUserHabits = true
        userHabits = await getUserHabits()
        loadingUserHabits = false
    }

    private func getUserHabits() async -> [Habits] {
        do {
            let userId = try await client.auth.session.user.id

            let query = client.database
                .from("habits")
                .select()
                .eq(column: "user_id", value: userId)

            let habits: [Habits] = try await query.execute().value

            let dateFormatter = DateFormatter()

            let dateNow = Date()
            let dateNowString = dateFormatter.string(from: dateNow)

            for i in 0 ..< habits.count {
                let habit = habits[i]

                // Check if lastUpdated is older than 2 days and update streak if needed
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let lastUpdatedDate = dateFormatter.date(from: habit.lastUpdate!),
                   let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())
                {
                    if lastUpdatedDate < twoDaysAgo {
                        // More than 2 days have passed since the last update, update streak

                        let newHabit = Habits(id: habit.id, name: habit.name, description: habit.description, userId: userId, streak: 0, lastUpdate: dateNowString)
                        try await client.database.from("habits")
                            .update(values: newHabit)
                            .eq(column: "id", value: habit.id!)
                            .single()
                            .execute()
                    }
                }
            }
            return habits
        } catch {
            print("### Error getUserHabits: \(error)")
            return []
        }
    }

    func removeHabit(habit: Habits) {
        Task {
            do {
                try await client.database.from("habits")
                    .delete()
                    .eq(column: "id", value: habit.id!)
                    .execute()
                print("removed")
            } catch {
                print("### Remove Error: \(error)")
            }
        }
    }

    func createUserHabit(name: String, description: String) {
        Task {
            do {
                let userId = try await self.client.auth.session.user.id

                let habit = Habits(id: nil, name: name, description: description, userId: userId, streak: nil, lastUpdate: nil)

                let query = self.client.database
                    .from("habits")
                    .insert(values: habit)
                try await query.execute().value
            } catch {
                print("### Error createUserHabit: \(error)")
            }
        }
    }

    func addStreakToUserHabit(habit: Habits) {
        Task {
            do {
                let streak = (habit.streak ?? 0) + 1

                try await client.database.from("habits")
                    .update(values: ["streak": streak])
                    .eq(column: "id", value: habit.id!)
                    .single()
                    .execute()

                await updateUserHabits()

            } catch {
                print("### Error addStreakToUserHabit: \(error)")
            }
        }
    }
}
