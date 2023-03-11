//
//  UserFriendsContentModel.swift
//  habit-tracker
//
//  Created by Louis AB on 04/03/2023.
//

import Foundation
import Supabase
import SupabaseStorage
import UIKit

class UserFriendsContentModel: ObservableObject {
    @Published var friendships = [Friendship]()

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @MainActor
    func updateUserFriendships() async {
        friendships = await getUserFriendships()
    }

    private func getUserFriendships() async -> [Friendship] {
        do {
            let userId = try await client.auth.session.user.id

            let query = client.database
                .from("friendships")
                .select()
                .eq(column: "user_id", value: userId)

            let ret: [Friendship] = try await query.execute().value

            return ret
        } catch {
            print("### Error getUserFriendships: \(error)")
            return []
        }
    }

    public func addUserFriendship(username: String) async {
        do {
            let userId = try await client.auth.session.user.id

            let friendUser: Users = try await client.database
                .from("users")
                .select()
                .eq(column: "username", value: username)
                .single()
                .execute()
                .value

            let newFriendship = Friendship(id: nil, userId: userId, friendId: friendUser.id)

            try await client.database
                .from("friendships")
                .insert(values: newFriendship)
                .execute()

        } catch {
            print("Error addUserFriendship: \(error)")
        }
    }
}
