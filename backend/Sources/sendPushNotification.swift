@preconcurrency import Appwrite
import Foundation
import JSONCodable
import Shared

@MainActor
public let processInfo = ProcessInfo.processInfo
@MainActor
public let PROJECT_ID = "67017126001e334dd053"
@MainActor
public let APPWRITE_API_KEY = processInfo.environment["APPWRITE_API_KEY"] ?? ""
@MainActor
public let DATABASE_ID = "orbit"
@MainActor
public let COLLECTION_ID = "users"

@MainActor
public let client: Client = {
    let client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject(PROJECT_ID)
        .setKey(APPWRITE_API_KEY)
    return client
}()

@MainActor
public let databases = Databases(client)

@MainActor
public let messaging = Messaging(client)

func sendNotification() async throws {

    let message = try await messaging.createPush(
        messageId: ID.unique(),
        title: "[TITLE]",
        body: "[BODY]",
        // topics: [],  // optional
        users: [
            "6726b1e615c56d9b9ab5"
        ]
        // targets: [],  // optional
        // data: [:],  // optional
        // action: "[ACTION]",  // optional
        // icon: "[ICON]",  // optional
        // sound: "[SOUND]",  // optional
        // color: "[COLOR]",  // optional
        // tag: "[TAG]",  // optional
        // badge: "[BADGE]",  // optional
        // draft: false  // optional
        //        scheduledAt: ""   optional
    )
}
@main
struct Main {
    static func main() async throws {
        try await sendNotification()
    }
}
