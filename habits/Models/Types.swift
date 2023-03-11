/// This file is generated automatically. Some types might not be perfectly corresponding to your database types.
/// For instance if your primary key is optionnal and is automatically generated when inserting new data, the id parameter will still be required in the generated code.
/// Please check the generated code and adapt it to your needs.

import Foundation

struct Habits: Codable, Identifiable {
    let id: Int? // Note: This is a Primary Key.<pk/>
    let name: String
    let description: String
    let userId: UUID
    let streak: Int?
    let lastUpdate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case userId = "user_id"
        case streak
        case lastUpdate = "last_update"
    }
}

struct Users: Codable {
    let id: UUID // Note: This is a Primary Key.<pk/>
    let username: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
    }
}

struct Friendship: Codable, Identifiable {
    let id: Int?
    let userId: UUID
    let friendId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
    }
}
