package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/appwrite/sdk-for-go/appwrite"
	"github.com/appwrite/sdk-for-go/id"
	"github.com/appwrite/sdk-for-go/models"

	"github.com/open-runtimes/types-for-go/v4/openruntimes"
)

/// TYPES
// Define a custom type
type Type string

// Define constants for each possible value
const (
	RequestApproved  Type = "requestApproved"
	NewMeetupRequest Type = "newMeetupRequest"
)

type Message struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

type Conversation struct {
	Id string `json:"id"`
	ReceiverName string `json:"receiverName"`
	SenderId string `json:"senderId"`
}

type Data struct {
	RequestId    string        `json:"requestId,omitempty"`    // Optional field
	Conversation *Conversation `json:"conversation,omitempty"` // Optional field
	Type    	 Type 		   `json:"type"`
	// TargetScreen string `json:"targetScreen"`
}

type RequestData struct {
	Message Message  `json:"message"`
	UserIds []string `json:"userIds"`
	Data    Data     `json:"data"`
	// either newMeetupRequest or requestApproved
	// DeviceToken string `json:"deviceToken"`
}

type ResponseData struct {
	Status 			int 		   `json:"status"`
	MessageResponse models.Message `json:"messageResponse"`
}

// Main function
func Main(Context openruntimes.Context) openruntimes.Response {
	// Create a new Appwrite client
	client := appwrite.NewClient(
		// appwrite.WithEndpoint(os.Getenv("APPWRITE_FUNCTION_API_ENDPOINT")),
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
		strings.Join(requestData.UserIds, ", ") + "\n"
		// + requestData.DeviceToken
		Context.Log("Data parsed successfully:\n" + combinedString)
	}

	notificationData, err := constructNotificationData(requestData.Data, Context)
	if err != nil {
		Context.Error(400, "Failed to parse data")
	}
	// Send a notification
	messaging := appwrite.NewMessaging(client)
	response, err := messaging.CreatePush(id.Unique(), requestData.Message.Title, requestData.Message.Body,
		messaging.WithCreatePushUsers(requestData.UserIds),
		messaging.WithCreatePushData(notificationData),
	)

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

func constructNotificationData(data Data, Context openruntimes.Context) (map[string]interface{}, error) {
    switch data.Type {
    case RequestApproved:
        if data.Conversation == nil {
			err := fmt.Errorf("conversation is nil")
			log.Printf("Failed to parse data for RequestApproved: %v", err)
			Context.Log("Failed to parse data for RequestApproved: " + err.Error())
            return nil, err
        }
        return map[string]interface{}{
            "conversation": data.Conversation,
            "type":         RequestApproved,
        }, nil
    case NewMeetupRequest:
        if data.RequestId == "" {
			err := fmt.Errorf("requestId is empty")
			log.Printf("Failed to parse data for NewMeetupRequest: %v", err)
			Context.Log("Failed to parse data for NewMeetupRequest: " + err.Error())
            return nil, err
        }
        return map[string]interface{}{
            "requestId": data.RequestId,
            "type":      NewMeetupRequest,
        }, nil
    default:
        return nil, fmt.Errorf("unknown data type given to constructNotificationData: %s", data.Type)
    }
}