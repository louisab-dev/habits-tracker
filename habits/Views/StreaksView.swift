//
//  StreaksView.swift
//  habit-tracker
//
//  Created by Louis AB on 27/02/2023.
//

import SwiftUI

struct StreaksView: View {
    @EnvironmentObject var userHabitModel: UserHabitsContentModel

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
                        ForEach(userHabitModel.userHabits) { habit in
                            HabitDetail(habit: habit)
                                .environmentObject(userHabitModel)
                        }
                        .listRowBackground(Color("Background"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .edgesIgnoringSafeArea(.all)
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task {
                            await userHabitModel.updateUserHabits()
                        }
                    }
                    .background(Color("Background"))
                    .scrollContentBackground(.hidden)
                }
                .accentColor(.white)
                .task {
                    await userHabitModel.updateUserHabits()
                }
            }
        }
    }
}

struct HabitDetail: View {
    var habit: Habits
    @EnvironmentObject var userHabitModel: UserHabitsContentModel

    var canUpdate: Bool {
        if habit.streak == 0 || habit.streak == nil {
            return true
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdatedDate = dateFormatter.date(from: habit.lastUpdate!) ?? Date()
        let currentDate = Date()

        let components = Calendar.current.dateComponents([.day], from: lastUpdatedDate, to: currentDate)
        if let days = components.day, days >= 1 {
            return true
        }

        return false
    }

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

                    Button(action: {
                        userHabitModel.removeHabit(habit: habit)
                        Task {
                            await userHabitModel.updateUserHabits()
                        }
                    }) {
                        Text("Remove Habit")
                            .font(.footnote)
                            .foregroundColor(Color("Gray2"))
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .background(
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(Color("Gray"))
                    )
                }

                Spacer()

                HStack {
                    Text(String(habit.streak ?? 0))
                    Image(systemName: "flame")
                }
                .foregroundColor(Color("Gray"))

                if canUpdate {
                    Button(action: {
                        userHabitModel.addStreakToUserHabit(habit: habit)
                        Task {
                            await userHabitModel.updateUserHabits()
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.horizontal)
                }
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

struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
    }
}
