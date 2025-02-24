struct FlowLayout<Item: Hashable, Content: View>: View {
        let items: [Item]
        let content: (Item) -> Content

        @State private var itemWidths: [Item: CGFloat] = [:]  // Store measured widths

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                generateContent()
            }
            .frame(maxWidth: .infinity, alignment: .leading)  // Ensure full width usage
        }

        private func generateContent() -> some View {
            var width: CGFloat = 0
            var rows: [[Item]] = [[]]

            for item in items {
                let itemWidth = itemWidths[item, default: 80] + 16  // Use stored width or default 80

                if width + itemWidth > UIScreen.main.bounds.width * 0.96 {
                    width = itemWidth
                    rows.append([item])
                } else {
                    width += itemWidth
                    rows[rows.count - 1].append(item)
                }
            }

            return VStack(alignment: .leading, spacing: 8) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { item in
                            measuredContent(for: item)
                        }
                    }
                }
            }
        }

        private func measuredContent(for item: Item) -> some View {
            content(item)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                DispatchQueue.main.async {
                                    itemWidths[item] = geometry.size.width
                                }
                            }
                    })
        }