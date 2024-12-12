//
//  MessageBox.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI
import MapKit

struct MessageBox: View {
    var messageDocument: MessageDocument
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var msgVM: MessagingViewModel
    @State private var showTime = false
    @State var isReceived = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var sharedLocation: CLLocationCoordinate2D?
    @State private var showFullMap = false

    var body: some View {
        let isReceived =
            messageDocument.data.senderAccountId
            != userVM.currentUser?.accountId
        VStack(alignment: isReceived ? .leading : .trailing) {
            HStack {
                //for messages that are locations
                if let location = msgVM.decodeCoordinate(from: messageDocument.data.message){
                    MapPreview(location: location)
                        .frame(width: 200, height: 150)
                        .cornerRadius(15)
                        .onTapGesture {
                            sharedLocation = location
                            showFullMap = true
                        }
                        .sheet(isPresented: $showFullMap){
                            ZStack{
                                Color(ColorPalette.background(for: colorScheme))
                                    .ignoresSafeArea(.all)
                                
                                VStack(spacing: 0){
                                    HStack {
                                        Button("Close"){
                                            showFullMap = false
                                        }
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                        
                                        Spacer()
                                    }
                                    .overlay(
                                        Text("Shared Location")
                                            .normalSemiBoldFont()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    )
                                    .padding()
                                    .background(ColorPalette.background(for: colorScheme).ignoresSafeArea(.all))
                                    
                                
                                    FullMapView(sharedLocation: location)
                                    
                                }
                                
                            }
                            
                        }
                        
                } else {
                    //regular messages
                    Text(messageDocument.data.message)
                        .padding()
                        .background(
                            isReceived
                            ? Color(.systemGray5)
                                : ColorPalette.accent(for: ColorScheme.light)
                        )
                        .cornerRadius(20)
                        .regularFont()
                    
                }
            }
            .frame(maxWidth: 300, alignment: isReceived ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }

            if showTime {
                Text(formatTimestamp(messageDocument.createdAt))
                    .regularFont()
                    .foregroundColor(.gray)
                    .padding(isReceived ? .leading : .trailing, 25)
            }

        }
        .frame(
            maxWidth: .infinity,
            alignment: isReceived ? .leading : .trailing
        )
        .padding(isReceived ? .leading : .trailing)
        .padding(.horizontal, 10)
    }

    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return "Unknown"
    }

}
