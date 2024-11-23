package main

import (
	"encoding/json"
	"log"
	"os"
	"strings"

	"github.com/appwrite/sdk-for-go/appwrite"
	"github.com/appwrite/sdk-for-go/id"
	"github.com/appwrite/sdk-for-go/models"
	"github.com/joho/godotenv"
	"github.com/open-runtimes/types-for-go/v4/openruntimes"
)

/// TYPES
type Message struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

type Data struct {
	UserIds []string `json:"userIds"`
}

type RequestData struct {
	Message Message `json:"message"`
	Data    Data    `json:"data"`
	DeviceToken string `json:"deviceToken"`
}

type ResponseData struct {
	Status int `json:"status"`
	MessageResponse models.Message `json:"messageResponse"`
}

// Main function
func Main(Context openruntimes.Context) openruntimes.Response {    // Load environment variables
    if err := godotenv.Load(); err != nil {
        log.Fatalf("Error loading .env file: %v", err)
    }
	// Create a new Appwrite client
	client := appwrite.NewClient(
		appwrite.WithProject(os.Getenv("APPWRITE_PROJECT_ID")),
		appwrite.WithKey(os.Getenv("APPWRITE_API_KEY")),
	)

	// Parse the data
	requestData, err := parseData(Context)
	if err != nil {
		Context.Error(400, "Failed to parse data")
	} else {
		// Combine the values into a single string with new line separators
		combinedString := requestData.Message.Title + "\n" +
		requestData.Message.Body + "\n" +
		strings.Join(requestData.Data.UserIds, ", ") + "\n" +
		requestData.DeviceToken
		Context.Log("Data parsed successfully:\n" + combinedString)
	}

	// Send a notification
	messaging := appwrite.NewMessaging(client)
	response, err := messaging.CreatePush(id.Unique(), "[TITLE]", "[BODY]", messaging.WithCreatePushUsers(requestData.Data.UserIds))
	if err != nil {
		log.Fatalf("Failed to send notification: %v", err)
	}

	log.Printf("Notification sent successfully: %+v", response)

	return Context.Res.Json(
		ResponseData{
			Status: 200,
			MessageResponse: *response,
		},
	)
}

/// HELPER FUNCTIONS
func parseData(Context openruntimes.Context) (RequestData, error) {
	// Parse the data
	var requestData RequestData

	err := json.Unmarshal(Context.Req.BodyBinary(), &requestData)
	if err != nil {
		log.Printf("Failed to parse data: %v", err)
		Context.Log("Failed to parse data: " + err.Error())
		return RequestData{}, err
	}

	return requestData, nil

}