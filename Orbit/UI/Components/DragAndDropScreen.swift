//
//  DragAndDropScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-23.
//
import SwiftUI

struct DragAndDropScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var availableItems = [
        "Finding like-minded friends to share hobbies",
        "Meeting people for intellectual or deep conversations",
        "Creating lasting friendships",
        "Dating",
        "Idk, I'm just a chill dude",
    ]
    @State private var basketItems: [String] = [
        "Idk, I'm just a chill dude"
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Question at the top
            Text("What brings you to Orbit?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            // Basket (Vertical List)
            VStack(spacing: 16) {
                Text("Your Basket")
                    .font(.headline)
                    .foregroundColor(.white)

                if basketItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.dotted")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))

                        Text("Drag up to 3 items here")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 150)
                } else {

                    // Basket Items (Draggable & Sortable)
                    VStack(spacing: 8) {
                        ForEach(Array(basketItems.enumerated()), id: \.element)
                        {
                            index, item in
                            BasketItemView(item: item)
                                .onDrag {
                                    NSItemProvider(object: item as NSString)
                                }
                                .onDrop(
                                    of: [.text],
                                    delegate: BasketDropDelegate(
                                        currentItem: item,
                                        basketItems: $basketItems,
                                        availableItems: $availableItems,
                                        currentIndex: index
                                    )
                                )

                        }
                        //                    .onDrop(
                        //                        of: [.text],
                        //                        delegate: BasketDropDelegate(
                        //                            currentItem: basketItems.last,
                        //                            basketItems: $basketItems,
                        //                            availableItems: $availableItems,
                        //                            currentIndex: basketItems.count - 1
                        //                        )
                        //                    )
                        .onMove(perform: moveBasketItem)  // ✅ Sorting enabled
                        //                    .onDrop(of: [.text], isTargeted: nil) { providers in
                        //                        if basketItems.count < 3 {
                        //                            return addItem(from: providers)
                        //                        }
                        //                        return false
                        //                    }
                    }
                    .padding()
                    .scrollContentBackground(.hidden)

                }
            }
            //            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                Color.accentColor.opacity(0.6), lineWidth: 1)
                    )
            )
            .onDrop(of: [.text], isTargeted: nil) { providers in
                if basketItems.count < 3 {
                    return addItem(from: providers)
                }
                return false
            }

            // Available Items List (Draggable)
            VStack(spacing: 8) {
                ForEach(availableItems, id: \.self) { item in
                    BasketItemView(item: item)
                        .onDrag {
                            NSItemProvider(object: item as NSString)
                        }

                }
                .onDrop(of: [.text], isTargeted: nil) { providers in
                    return handleDropInAvailableItems(from: providers)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
        .padding(.horizontal)
        .toolbar {
            EditButton()
        }
        //        .frame(maxHeight: .infinity)
        .background(ColorPalette.background(for: colorScheme))
    }

    /// Adds an item to the basket & removes from list
    private func addItem(from providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadObject(ofClass: NSString.self) { (data, error) in
                if let newItem = data as? String {
                    DispatchQueue.main.async {
                        if !basketItems.contains(newItem), basketItems.count < 3
                        {
                            basketItems.append(newItem)
                            availableItems.removeAll { $0 == newItem }  // ✅ Remove from list
                        }
                    }
                }
            }
        }
        return true
    }

    /// Moves an item inside the basket
    private func moveBasketItem(from source: IndexSet, to destination: Int) {
        basketItems.move(fromOffsets: source, toOffset: destination)
    }

    /// Handles items being dropped back into available items list
    private func handleDropInAvailableItems(from providers: [NSItemProvider])
        -> Bool
    {
        for provider in providers {
            provider.loadObject(ofClass: NSString.self) { (data, error) in
                if let droppedItem = data as? String {
                    DispatchQueue.main.async {
                        if basketItems.contains(droppedItem) {
                            basketItems.removeAll { $0 == droppedItem }
                            if !availableItems.contains(droppedItem) {
                                availableItems.append(droppedItem)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}

/// Handles reordering inside the basket and returning items
struct BasketDropDelegate: DropDelegate {
    let currentItem: String
    @Binding var basketItems: [String]
    @Binding var availableItems: [String]
    let currentIndex: Int

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }

        itemProvider.loadObject(ofClass: NSString.self) { (data, error) in
            if let droppedItem = data as? String {
                DispatchQueue.main.async {
                    if let oldIndex = basketItems.firstIndex(of: droppedItem) {
                        // ✅ Sort inside the basket
                        basketItems.move(
                            fromOffsets: IndexSet(integer: oldIndex),
                            toOffset: currentIndex
                        )
                    } else if basketItems.count < 3 {
                        // ✅ Add new item to basket
                        basketItems.insert(droppedItem, at: currentIndex + 1)
                        availableItems.removeAll { $0 == droppedItem }  // ✅ Remove from list
                    }
                }
            }
        }
        return true
    }
}

/// Basket Item View (Draggable)
struct BasketItemView: View {
    let item: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .opacity(0.7)
            Text(item)
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // Align items to the left
        //        .contentShape(Rectangle())
        .padding(.vertical, 14)
        .padding(.horizontal)
        .background(Color.accentColor.opacity(0.2))  // Match basket item style
        .cornerRadius(10)
    }
}

#Preview {
    DragAndDropScreen()
}
