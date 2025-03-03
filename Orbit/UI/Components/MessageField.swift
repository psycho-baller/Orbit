//
//  MessageField.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-03.
//

import SwiftUI


struct MessageField: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text : String //the state that changes when uesr inputs into message field
    var onSend: () -> Void
    
    var body: some View {
        HStack{
            CustomTextField(placeholder: Text("Message..."), text: $text)
            
            Button(action: { onSend()})
            {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(colorScheme == .light ? .white : Color(.systemGray5))
                    .padding(10)
                    .background(ColorPalette.accent(for: ColorScheme.light))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        //.background(Color(red: 0.929, green: 0.929, blue: 0.929))
        .background(colorScheme == .light ? Color(red: 0.929, green: 0.929, blue: 0.929) : Color(.systemGray5))
        .cornerRadius(50)
        .padding()
        
    }
}

#Preview {
    MessageField(text: .constant("")){
        print("Send button pressed")
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String  //can pass variable text from one view to another
    var editingChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .opacity(0.5)
            }
            
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
