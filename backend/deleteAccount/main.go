package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/appwrite/sdk-for-go/appwrite"
	"github.com/open-runtimes/types-for-go/v4/openruntimes"
)

// TYPES
type AccountType string

// const (
//     UserAccount AccountType = "userAccount"
//     AdminAccount AccountType = "adminAccount"
// )

type AccountData struct {
    AccountId string `json:"accountId"`
    Type      AccountType `json:"type"`
}

type requestData struct {
    AccountId string      `json:"accountId"`
    // Type      AccountType `json:"type"`
}

type responseData struct {
    Status int `json:"status"`
    Success bool `json:"success"`
}

// Main function
func Main(Context openruntimes.Context) openruntimes.Response {
    // Create a new Appwrite client
    client := appwrite.NewClient(
        appwrite.WithEndpoint(os.Getenv("APPWRITE_FUNCTION_API_ENDPOINT")),
        appwrite.WithProject(os.Getenv("APPWRITE_PROJECT_ID")),
        appwrite.WithKey(os.Getenv("APPWRITE_API_KEY")),
    )

    // Parse the data
    requestDataFromClient, err := parseData(Context)
    if err != nil {
        Context.Error(400, "Failed to parse data")
        return Context.Res.Json(
            responseData{
                Status: 400,
                Success: false,
            },
        )
    }

    // Validate input
    if err := validateInput(requestDataFromClient); err != nil {
        Context.Error(400, err.Error())
        return Context.Res.Json(
            responseData{
                Status: 400,
                Success: false,
            },
        )
    }

    // Delete the account
    users := appwrite.NewUsers(client)
    response, err := users.Delete(requestDataFromClient.AccountId)

    if err != nil {
        log.Printf("Failed to delete account: %v", err)
        Context.Log("Failed to delete account: " + err.Error())
        return Context.Res.Json(
            responseData{
                Status: 500,
                Success: false,
            },
        )
    }

    log.Printf("Account deleted successfully: %+v", response)
    return Context.Res.Json(
        responseData{
            Status: 200,
            Success: true,
        },
    )
}

/// HELPER FUNCTIONS
func parseData(Context openruntimes.Context) (requestData, error) {
	// Parse the data
	var requestData requestData

	err := json.Unmarshal(Context.Req.BodyBinary(), &requestData)
	if err != nil {
		log.Printf("Failed to parse data: %v", err)
		Context.Log("Failed to parse data: " + err.Error())
		return requestData, err
	}

	return requestData, nil

}

func validateInput(data requestData) error {
    if data.AccountId == "" {
        return fmt.Errorf("account ID cannot be empty")
    }
    // if data.Type != UserAccount && data.Type != AdminAccount {
    //     return fmt.Errorf("invalid account type")
    // }
    return nil
}
