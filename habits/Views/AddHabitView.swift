//
//  AddHabitView.swift
//  habit-tracker
//
//  Created by Louis AB on 01/03/2023.
//

import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var userHabitModel: UserHabitsContentModel
    @Environment(\.dismiss) var dismiss

    @State private var habitName: String = ""
    @State private var habitDescription: String = ""

    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(Color("Background"))

            VStack(alignment: .center) {
                Text("New Habit")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.footnote)
                        .foregroundColor(.white)

                        .padding(.top)
                    TextField("", text: $habitName)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Description")
                        .font(.footnote)
                        .foregroundColor(.white)

                        .padding(.top)
                    TextField("", text: $habitDescription)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .frame(height: 50, alignment: .center)
                        .padding(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("Purple"), lineWidth: 1)
                                .foregroundColor(.orange)
                        )
                        .padding(.top, 2)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }

                Spacer()

                Button(action: {
                    userHabitModel.createUserHabit(name: habitName, description: habitDescription)
                    dismiss()
                }) {
                    Text("Create habit")
                        .padding(.vertical)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .accentColor(.white)
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(Color("Gray"))
                )

                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
