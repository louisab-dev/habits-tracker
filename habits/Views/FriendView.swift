//
//  FriendView.swift
//  habit-tracker
//
//  Created by Louis AB on 04/03/2023.
//

import Supabase
import SwiftUI

struct FriendView: View {
    var friendId: UUID

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @State var friendHabits = [Habits]()

    func updateFriendHabits() async {
        do {
            let query = client.database
                .from("habits")
                .select()
                .eq(column: "user_id", value: friendId)

            friendHabits = try await query.execute().value

        } catch {
            print("### error updateFriendHabits: \(error)")
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(Color("Background"))

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 0) {
                    Text("Streaks")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)

                NavigationView {
                    List {
                        ForEach(friendHabits) { habit in
                            FriendHabitDetail(habit: habit)
                        }
                        .listRowBackground(Color("Background"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .edgesIgnoringSafeArea(.all)
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task {
                            await updateFriendHabits()
                        }
                    }
                    .background(Color("Background"))
                    .scrollContentBackground(.hidden)
                }
                .accentColor(.white)
                .task {
                    await updateFriendHabits()
                }
            }
        }
    }
}

struct FriendHabitDetail: View {
    var habit: Habits

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.title)
                        .foregroundColor(Color("Gray"))
                    Text(habit.description)
                        .font(.footnote)
                        .foregroundColor(Color("Gray"))
                }

                Spacer()

                HStack {
                    Text(String(habit.streak ?? 0))
                    Image(systemName: "flame")
                }
                .foregroundColor(Color("Gray"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .foregroundColor(Color("Gray2"))
                .cornerRadius(10)
        )
    }
}
