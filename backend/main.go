package main

import (
	"log"
	"os"

	"github.com/appwrite/sdk-for-go/appwrite"
	"github.com/appwrite/sdk-for-go/id"
	"github.com/joho/godotenv"
)

func main() {
    // Load environment variables
    if err := godotenv.Load(); err != nil {
        log.Fatalf("Error loading .env file: %v", err)
    }
	// Create a new Appwrite client
	client := appwrite.NewClient(
		appwrite.WithProject(os.Getenv("APPWRITE_PROJECT_ID")),
		appwrite.WithKey(os.Getenv("APPWRITE_API_KEY")),
	)

	// Initialize Messaging service
	messaging := appwrite.NewMessaging(client)
	usersToSendNotifTo := []string{
		"6726b1e615c56d9b9ab5",
	}

	// Send a notification
	response, err := messaging.CreatePush(id.Unique(), "[TITLE]", "[BODY]", messaging.WithCreatePushUsers(usersToSendNotifTo))
	if err != nil {
		log.Fatalf("Failed to send notification: %v", err)
	}

	log.Printf("Notification sent successfully: %s", response)
}
