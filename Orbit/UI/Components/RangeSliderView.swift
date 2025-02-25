import SwiftUI

struct RangeSliderView: View {
    @Binding var selectedMin: Int
    @Binding var selectedMax: Int
    let minValue: Int
    let maxValue: Int

    var body: some View {
        VStack {
            Slider(value: Binding(
                get: { Double(selectedMin) },
                set: { selectedMin = Int($0) }
            ), in: Double(minValue)...Double(selectedMax - 1), step: 1)
            
            Slider(value: Binding(
                get: { Double(selectedMax) },
                set: { selectedMax = Int($0) }
            ), in: Double(selectedMin + 1)...Double(maxValue), step: 1)

            HStack {
                Text("\(selectedMin)")
                Spacer()
                Text("\(selectedMax)")
            }
            .font(.subheadline)
        }
        .padding()
    }
}
