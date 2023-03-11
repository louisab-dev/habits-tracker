//
//  UserSettingsModel.swift
//  habit-tracker
//
//  Created by Louis AB on 02/03/2023.
//

import Foundation
import Supabase
import SupabaseStorage
import UIKit

class UserSettingsContentModel: ObservableObject {
    @Published var userProfilePictureURL: String = ""
    @Published var userHasProfilePicture: Bool = false
    @Published var username: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    @MainActor
    func setProfilePicture() async {
        self.username = await self.getUsername()
        self.userHasProfilePicture = await self.checkIfUserHasProfilePicture()
        if self.userHasProfilePicture {
            self.userProfilePictureURL = await self.getProfilePictureUrl()
        }
    }

    func checkIfUserHasProfilePicture() async -> Bool {
        do {
            let userId = try await self.client.auth.session.user.id
            let fileList = try await client.storage.from(id: "images").list(path: userId.uuidString)
            return fileList.count != 0
        } catch {
            print("### LIST Error: \(error)")
            return false
        }
    }

    /// Assumes that the profile picture is stored in the bucket
    /// Would be nice to update it when https://github.com/supabase-community/storage-swift/pull/11 is merged using getPublicUrl
    func getProfilePictureUrl() async -> String {
        do {
            let userId = try await self.client.auth.session.user.id
            let profilePictureUrl = Constants.supabaseUrl + "/storage/v1/object/public/images/\(userId)/\(userId).png"
            return profilePictureUrl
        } catch {
            print("### getProfilePictureUrl Error: \(error)")
            return ""
        }
    }

    func uploadProfilePicture(profilePicture: UIImage) async {
        do {
            let userId = try await self.client.auth.session.user.id

            let file = File(
                name: "image",
                data: profilePicture.pngData()!,
                fileName: "\(userId).png",
                contentType: "image/png"
            )

            _ = try await self.client.storage.from(id: "images").upload(path: "\(userId)/\(userId).png", file: file, fileOptions: nil)
        } catch {
            print("### Upload PFP Error: \(error)")
        }
    }

    /// Assumes that there is already a profile picture in the bucket
    func updateProfilePicture(profilePicture: UIImage) async {
        do {
            let userId = try await self.client.auth.session.user.id

            let file = File(
                name: "image",
                data: profilePicture.pngData()!,
                fileName: "\(userId).png",
                contentType: "image/png"
            )

            _ = try await self.client.storage.from(id: "images").update(path: "\(userId)/\(userId).png", file: file, fileOptions: nil)
        } catch {
            print("### Upload PFP Error: \(error)")
        }
    }

    func getUsername() async -> String {
        do {
            let userId = try await self.client.auth.session.user.id

            let user: Users = try await self.client.database.from("users").select().eq(column: "id", value: userId).single().execute().value

            return user.username

        } catch {
            print("error getUsername: \(error)")

            do {
                await self.createUsername()

                let userId = try await self.client.auth.session.user.id

                let user: Users = try await self.client.database.from("users").select().eq(column: "id", value: userId).single().execute().value

                return user.username
            } catch {
                return ""
            }
        }
    }

    func updateUsername(newUsername: String) async {
        do {
            let userId = try await self.client.auth.session.user.id

            _ = try await self.client.database.from("users").update(values: ["username": newUsername]).eq(column: "id", value: userId).single().execute()
        } catch {
            print("error updateUsername: \(error)")
        }
    }

    func createUsername() async {
        do {
            let userId = try await self.client.auth.session.user.id

            let newUser = Users(id: userId, username: userId.uuidString)

            _ = try await self.client.database.from("users").insert(values: newUser).execute()
        } catch {
            print("Error creating username")
        }
    }
}
