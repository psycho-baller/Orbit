@preconcurrency import Appwrite
import Foundation
import JSONCodable
import Shared

func deleteUnmatchedUsers() async {
    do {
        print("Fetching all users...")
        // Fetch all Appwrite users
        let userList = try await users.list()

        print("Fetched \(userList.users.count) users")
        // Fetch all accountIds from your users collection
        let accountIds = try await fetchAccountIds()

        for user in userList.users {
            if !accountIds.contains(user.id) {
                do {
                    try await users.delete(userId: user.id)
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
    do {
        print("Fetching all documents...")
        let documents = try await databases.listDocuments(
            databaseId: DATABASE_ID,
            collectionId: COLLECTION_ID
            // queries: [Query.select(["accountId"])]
            // limit: 100,
            // cursor: cursor
        )
        print("Fetched \(documents.documents.count) documents")
        for doc in documents.documents {
            if let data = doc.data as? [String: AnyCodable],
                let accountId = data["accountId"] as? String,
                !accountId.isEmpty
            {
                accountIds.insert(accountId)
            } else {
                print("Warning: Document data is missing 'accountId' or is invalid.")
            }
        }
    } catch {
        print("Error fetching documents: \(error.localizedDescription)")
    }
    // cursor = documents.cursor
    // } while cursor != nil

    return accountIds
}

@main
struct DeleteAllUnusedAuthUsers {
    static func main() async {
        await deleteUnmatchedUsers()
    }
}
