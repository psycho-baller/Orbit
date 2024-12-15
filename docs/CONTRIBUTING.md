# Contributing

## Background Information

### User journey flow

- this uses mermaid syntax. You can use the [mermaid live editor](https://mermaid.live/) to visualize the diagram

```mermaid
flowchart TD
 subgraph Campus_Geofencing["Campus_Geofencing"]
        D["Detect Campus Entry or Exit"]
        C["CampusLocationManager Geofence"]
        E["Activate Precise Location Tracking"]
        F["Stop Tracking"]
  end
 subgraph Location_Identification["Location_Identification_Backend"]
        H["Calculate Nearest Area"]
        G["Precise Location Tracking with 10m Accuracy"]
        I["Update Backend with Area Name"]
  end
 subgraph Frontend["Frontend"]
        J["Display Current Area to User"]
        K["Show Users in Same Area"]
  end
 subgraph Meetup_Process["Meetup_Process"]
        L["User A Requests Meetup with User B"]
        M["Notify User B for Approval"]
        N{"Approval Granted?"}
        O["Redirect to Chat Interface"]
        P["End Request"]
  end
 subgraph Chat_Interface["Chat_Interface"]
        Q["Chat Interface for Planning Meetup"]
        R{"Request Precise Location Sharing?"}
        S["Enable High-Accuracy Mode for Map"]
        T["Continue in Chat"]
        U["Share Precise Location on Map"]
        V{"Meetup Concluded or Cancelled?"}
        W["Return to Home Page"]
  end
    C --> D
    D -- Enter --> E
    D -- Exit --> F
    G --> H
    H --> I
    I --> J
    J --> K
    K --> L
    L --> M
    M --> N
    N -- Yes --> O
    N -- No --> P
    O --> Q
    Q --> R
    R -- Yes --> S
    R -- No --> T
    S --> U
    U --> V
    V -- Yes --> W
    V -- No --> Q
    E --> G
```

## Prerequisites

## Development

## Production

## Testing