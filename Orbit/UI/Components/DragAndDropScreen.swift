//
//  DragAndDropScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-23.
//
import SwiftUI

struct DragAndDropScreen: View {
    var title: String
    var description: String
    var maxBasketItems: Int = 3
    var basketTitle: String = "Your Basket"
    var emptyBasketText: String? = nil
    var emptyBasketImage: String = "arrow.down.circle.dotted"
    @Environment(\.colorScheme) var colorScheme
    @Binding var availableItems: [String]
    @Binding var basketItems: [String]

    var body: some View {
        VStack(spacing: 24) {
            // Question at the top
            //            Text(title)
            //                .font(.title2)
            //                .fontWeight(.bold)
            //                .multilineTextAlignment(.center)
            //                .padding()

            // Description
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()

            // Basket (Vertical List)
            VStack(spacing: 16) {
                Text(basketTitle)
                    .font(.headline)
                    .foregroundColor(.white)

                if basketItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: emptyBasketImage)
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))

                        //                        Text(
                        //                            emptyBasketText
                        //                                ? emptyBasketText
                        //                                : "Drag up to \(maxBasketItems) items here"
                        //                        )
                        //                        .font(.subheadline)
                        //                        .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
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
                        .onMove(perform: moveBasketItem)  // ✅ Sorting enabled
                    }
                    .padding()
                    .scrollContentBackground(.hidden)

                }
            }
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
                if basketItems.count < maxBasketItems {
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
        .navigationTitle(title)
        //        .frame(maxHeight: .infinity)
        .background(ColorPalette.background(for: colorScheme))
    }

    /// Adds an item to the basket & removes from list
    private func addItem(from providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadObject(ofClass: NSString.self) { (data, error) in
                if let newItem = data as? String {
                    DispatchQueue.main.async {
                        if !basketItems.contains(newItem),
                            basketItems.count < maxBasketItems
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
        .padding(.vertical, 14)
        .padding(.horizontal)
        .background(Color.accentColor.opacity(0.2))  // Match basket item style
        .cornerRadius(10)
    }
}

#Preview {
    DragAndDropScreen(
        title: "What brings you to Orbit?",
        description: "Choose your interests from the list below.",
        availableItems: .constant(
            [
                "Making friends who share my interests and hobbies",
                "Having meaningful conversations and deep discussions",
                "Building long-term friendships",
                "Exploring romantic relationships",
            ]
        ),
        basketItems: .constant([
            //            "Idk, I'm just a chill guy"
        ])
    )
}
