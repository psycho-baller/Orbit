@preconcurrency import Appwrite
import Foundation
import JSONCodable
import Shared

func setupNotification() async throws {

    // let provider = try await messaging.updateApnsProvider(
    //     providerId: "rami-notifs",
    //     name: "[NAME]",  // optional
    //     enabled: true,  // optional
    //     authKey: "[AUTH_KEY]",  // optional
    //     authKeyId: "[AUTH_KEY_ID]",  // optional
    //     teamId: "[TEAM_ID]",  // optional
    //     bundleId: "[BUNDLE_ID]"  // optional
    // )
}

func sendNotification() async throws {

    let message = try await messaging.createPush(
        messageId:  ID.unique(),
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
        // try await setupNotification()
        try await sendNotification()
    }
}
