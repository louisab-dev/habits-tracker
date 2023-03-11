//
//  HomeView.swift
//  habit-tracker
//
//  Created by Louis AB on 27/02/2023.
//

import Supabase
import SwiftUI

struct HomeView: View {
    @State private var showAddHabit: Bool = false
    @State private var showModalFriend: Bool = false
    @State private var username: String = ""

    @EnvironmentObject var userFriendsContentModel: UserFriendsContentModel

    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(Color("Background"))

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 0) {
                    Text("Home")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        showModalFriend = true
                    }) {
                        Text("Invite Friends")
                            .padding(.horizontal)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Purple"))
                    }
                    .accentColor(.white)
                    .background(
                        Rectangle()
                            .cornerRadius(10)
                            .frame(height: 40)
                            .foregroundColor(Color("Gray2"))
                    )
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)

                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Text("FRIENDS")
                            .foregroundColor(Color("Gray"))
                            .font(.headline)
                        Spacer()
                    }
                    FriendsView()
                        .environmentObject(userFriendsContentModel)

                    Button(action: {
                        showAddHabit = true
                    }) {
                        Text("Add habit")
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
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)

                Spacer()
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
        }
        .task {
            await userFriendsContentModel.updateUserFriendships()
        }
        .sheet(isPresented: $showModalFriend) {
            ZStack {
                Rectangle()
                    .foregroundColor(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                VStack {
                    TextField("Enter the username", text: $username)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)

                    Button("Add friend") {
                        Task {
                            await userFriendsContentModel.addUserFriendship(username: username)
                            await userFriendsContentModel.updateUserFriendships()
                        }
                        showModalFriend = false
                    }
                    .padding()
                    .background(Color("Gray"))
                    .foregroundColor(.white)
                    .cornerRadius(10.0)
                }
                .padding()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserFriendsContentModel())
    }
}

struct FriendsView: View {
    @EnvironmentObject var userFriendsContentModel: UserFriendsContentModel

    @State var currentFriend: Friendship?

    var body: some View {
        VStack {
            if userFriendsContentModel.friendships.count == 0 {
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color("Purple"))
                    .font(.system(size: 60))
                    .frame(width: 200, height: 200)
                    .background(
                        Circle()
                            .foregroundColor(Color("Gray2"))
                    )

                VStack(spacing: 0) {
                    Text("Personnal growth is easier with friends!")

                    Text("Invite some friends")
                }
                .foregroundColor(Color("Gray"))
                .font(.headline)

                Spacer()
            } else {
                ScrollView {
                    ForEach(userFriendsContentModel.friendships) { friendship in
                        FriendRow(userId: friendship.friendId)
                            .onTapGesture {
                                self.currentFriend = friendship
                            }
                    }
                }
                .sheet(item: $currentFriend, onDismiss: {
                    self.currentFriend = nil
                }) {
                    FriendView(friendId: $0.friendId)
                }
            }
        }
    }
}

struct FriendRow: View {
    var userId: UUID

    var profilePictureUrl: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @State private var username: String?

    func getUsername() async {
        do {
            let result: Users = try await client.database.from("users").select().eq(column: "id", value: userId).single().execute().value
            username = result.username
        } catch {
            print("Error getUsername: \(error)")
            username = "not found"
        }
    }

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: Constants.supabaseUrl + "/storage/v1/object/public/images/\(userId).png")) { image in
                image.resizable()
                    .clipShape(
                        Circle()
                    )
            } placeholder: {
                Image(systemName: "person.fill")
                    .clipShape(Circle())
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .overlay(
                Circle()
                    .stroke(Color("Purple"), lineWidth: 2)
            )

            VStack {
                if let username = username {
                    Text(username)
                        .foregroundColor(.white)
                        .font(.headline)
                } else {
                    ProgressView()
                        .onAppear {
                            Task {
                                await getUsername()
                            }
                        }
                }
            }

            Spacer()
        }
        .padding(.top)
    }
}

struct ScrollFriendsList: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                // Your scroll view content goes here
                Text("Scroll View Content")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }

            Button(action: {
                // Handle button tap action
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(width: 70, height: 70)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .padding()
            })
        }
    }
}
