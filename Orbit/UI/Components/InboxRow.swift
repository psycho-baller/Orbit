//
//  InboxRow.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct InboxRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(.systemGray4))
            
            VStack (alignment: .leading, spacing: 4){
                Text("Makka Pakka")
                    .normalSemiBoldFont()
                
                Text("Makka Pakka Wakka Akka. Makka Pakka is coming for you")
                    .regularFont()
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading )
            }
            
            HStack{
                Text("Yesterday")
                Image(systemName: "chevron.right")
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }
        .padding(.horizontal)
        .frame(height: 72)
        
    }
}

#Preview {
    InboxRow()
}
