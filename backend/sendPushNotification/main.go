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
type Type string

const (
	MeetupApproved Type = "meetupApproved"
	NewMessage     Type = "newMessage"
)

type Message struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

// NewMessageData defines the payload for a new message notification.
type NewMessageData struct {
	Id             string `json:"id"`
	SentByUserId   string `json:"sentByUserId"`
	ReceiverUserId string `json:"receiverUserId"`
	ChatId         string `json:"chatId"`
}

// MeetupRequestData defines the payload for a meetup approval notification.
type MeetupRequestData struct {
	Id              string `json:"id"`
	CreatedByUserId string `json:"createdByUserId"`
	ApproverUserId  string `json:"approverUserId"`
}

// Data now supports two possible payloads: one for new messages and one for meetup approvals.
type Data struct {
	NewMessage    *NewMessageData    `json:"newMessage,omitempty"`
	MeetupRequest *MeetupRequestData `json:"meetupRequest,omitempty"`
	Type          Type               `json:"type"`
}

type RequestData struct {
	Message Message  `json:"message"`
	UserIds []string `json:"userIds"`
	Data    Data     `json:"data"`
}

type ResponseData struct {
	Status          int            `json:"status"`
	MessageResponse models.Message `json:"messageResponse"`
}

// Main function
func Main(Context openruntimes.Context) openruntimes.Response {
	// Create a new Appwrite client
	client := appwrite.NewClient(
		appwrite.WithProject(os.Getenv("APPWRITE_PROJECT_ID")),
		appwrite.WithKey(os.Getenv("APPWRITE_API_KEY")),
	)

	// Parse the data
	requestData, err := parseData(Context)
	if err != nil {
		Context.Error(400, "Failed to parse data")
		return Context.Res.Json(map[string]string{"error": "Failed to parse data"})
	} else {
		combinedString := requestData.Message.Title + "\n" +
			requestData.Message.Body + "\n" +
			strings.Join(requestData.UserIds, ", ") + "\n"
		Context.Log("Data parsed successfully:\n" + combinedString)
	}

	notificationData, err := constructNotificationData(requestData.Data, Context)
	if err != nil {
		Context.Error(400, "Failed to parse notification data")
		return Context.Res.Json(map[string]string{"error": "Failed to parse notification data"})
	}

	// Send a push notification
	messaging := appwrite.NewMessaging(client)
	response, err := messaging.CreatePush(
		id.Unique(),
		requestData.Message.Title,
		requestData.Message.Body,
		messaging.WithCreatePushUsers(requestData.UserIds),
		messaging.WithCreatePushData(notificationData),
	)

	if err != nil {
		log.Fatalf("Failed to send notification: %v", err)
	}

	log.Printf("Notification sent successfully: %+v", response)

	return Context.Res.Json(
		ResponseData{
			Status:          200,
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
	case MeetupApproved:
		if data.MeetupRequest == nil {
			err := fmt.Errorf("meetupRequest is nil")
			log.Printf("Failed to parse data for MeetupApproved: %v", err)
			Context.Log("Failed to parse data for MeetupApproved: " + err.Error())
			return nil, err
		}
		return map[string]interface{}{
			"meetupRequest": data.MeetupRequest,
			"type":          MeetupApproved,
		}, nil
	case NewMessage:
		if data.NewMessage == nil {
			err := fmt.Errorf("newMessage is nil")
			log.Printf("Failed to parse data for NewMessage: %v", err)
			Context.Log("Failed to parse data for NewMessage: " + err.Error())
			return nil, err
		}
		return map[string]interface{}{
			"newMessage": data.NewMessage,
			"type":       NewMessage,
		}, nil
	default:
		return nil, fmt.Errorf("unknown data type given to constructNotificationData: %s", data.Type)
	}
}