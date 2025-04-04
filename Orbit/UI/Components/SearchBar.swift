//
//  SearchBar.swift
//  Orbit
//
//  Created by Alexey Naumov on 14.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String = ""  // Add a placeholder property
    var cancelButtonColor: UIColor = .red

    func makeUIView(context: UIViewRepresentableContext<SearchBar>)
        -> UISearchBar
    {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        
        searchBar.searchBarStyle = .minimal  // Removes the default background and border
        searchBar.backgroundImage = UIImage()  // Removes background image to make it clear
        
        // Customize the search text field
        if let textField = searchBar.searchTextField as UITextField? {
            textField.backgroundColor = UIScreen.main.traitCollection.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "#ACC9E3").opacity(0.15))
            : UIColor(Color(hex: "#448c89").opacity(0.15))
            textField.textColor = .white  // White text color
            textField.tintColor = .white  // White cursor and text input highlight
            textField.layer.cornerRadius = 10  // Rounded corners
            textField.clipsToBounds = true  // Apply corner radius
        }
        
        searchBar.tintColor = cancelButtonColor
        
        return searchBar
    }

    func updateUIView(
        _ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>
    ) {
        uiView.text = text
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
}

extension SearchBar {
    final class Coordinator: NSObject, UISearchBarDelegate {

        private let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func searchBar(
            _ searchBar: UISearchBar, textDidChange searchText: String
        ) {
            text.wrappedValue = searchText
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }

        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(false, animated: true)
            return true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            searchBar.text = ""
            text.wrappedValue = ""
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}
