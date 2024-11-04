//
//  MessagesList.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct MessagesList: View {
    var body: some View {
        List{
            ForEach(0 ... 10, id: \.self){
                message in InboxRow()
            }
        }
        .listStyle(PlainListStyle())
        .frame(height: UIScreen.main.bounds.height - 120)
    }
}

#Preview {
    MessagesList()
}
