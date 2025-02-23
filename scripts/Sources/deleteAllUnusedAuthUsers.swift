@preconcurrency import Appwrite
import Foundation
import JSONCodable
import Shared

func deleteUnmatchedUsers() async {
    do {
        print("Fetching all users...")
        var allUsers: [AppwriteModels.User<[String: AnyCodable]>] = []
        var offset = 0
        let limit = 150  // Fetch 100 users at a time

        // Keep fetching users until we get less than the limit (meaning we've reached the end)
        while true {
            let userList = try await users.list(
                queries: [
                    Query.limit(limit),
                    Query.offset(offset),
                ]
            )
            allUsers.append(contentsOf: userList.users)
            print(
                "Fetched \(userList.users.count) users (total: \(allUsers.count))"
            )

            if userList.users.count < limit {
                break  // We've fetched all users
            }
            offset += limit
        }

        print("Total users fetched: \(allUsers.count)")

        // Print details for all users
//        for user in allUsers {
//            print("User: \(user.id)")
//            print("Email: \(user.email)")
//            print("Name: \(user.name)")
//            print("Created at: \(user.createdAt)")
//            print("Updated at: \(user.updatedAt)")
//            print("")
//        }

        // Fetch all accountIds from your users collection
        let accountIds = try await fetchAccountIds()
        print("Found \(accountIds.count) account IDs in the database")

        // Delete users not found in the database
        for user in allUsers {
            if !accountIds.contains(user.id) {
                do {
                    let res = try await users.delete(userId: user.id)
                    print("confirmation: \(res)")
                    print("Deleted user: \(user.id)")
                } catch {
                    print(
                        "Error deleting user \(user.id): \(error.localizedDescription)"
                    )
                }
            } else {
                print("Skipping user \(user.id) as it matches an accountId")
            }
        }

        print("Deletion process completed")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

func fetchAccountIds() async throws -> Set<String> {
    var accountIds = Set<String>()
    var offset = 0
    let limit = 100  // Fetch 100 documents at a time

    while true {
        do {
            print("Fetching documents (offset: \(offset))...")
            let documents = try await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: COLLECTION_ID,
                queries: [
                    Query.limit(limit),
                    Query.offset(offset),
                ]
            )

            print("Fetched \(documents.documents.count) documents")

            for doc in documents.documents {
                if let data = doc.data as? [String: AnyCodable],
                    let accountId = data["accountId"] as? String,
                    !accountId.isEmpty
                {
                    accountIds.insert(accountId)
                } else {
                    print(
                        "Warning: Document \(doc.id) is missing 'accountId' or is invalid."
                    )
                }
            }

            if documents.documents.count < limit {
                break  // We've fetched all documents
            }
            offset += limit

        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
            throw error
        }
    }

    print("Total unique account IDs found: \(accountIds.count)")
    return accountIds
}

@main
struct DeleteAllUnusedAuthUsers {
    static func main() async {
        await deleteUnmatchedUsers()
    }
}
