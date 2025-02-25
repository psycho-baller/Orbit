//
//  RangeSliderView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-25.
//

import SwiftUI

struct RangeSliderView: View {
    @Binding var lowerValue: Int
    @Binding var upperValue: Int
    let range: ClosedRange<Int>

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: trackHeight)
                    .cornerRadius(trackHeight / 2)

                // Selected range
                Rectangle()
                    .fill(Color.blue)
                    .frame(
                        width: CGFloat(upperValue - lowerValue)
                            / CGFloat(range.upperBound - range.lowerBound)
                            * geometry.size.width, height: trackHeight
                    )
                    .offset(
                        x: CGFloat(lowerValue - range.lowerBound)
                            / CGFloat(range.upperBound - range.lowerBound)
                            * geometry.size.width
                    )
                    .cornerRadius(trackHeight / 2)

                // Thumbs
                Group {
                    // Lower thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 2)
                        .offset(
                            x: CGFloat(lowerValue - range.lowerBound)
                                / CGFloat(range.upperBound - range.lowerBound)
                                * geometry.size.width - thumbSize / 2
                        )
                        .gesture(
                            DragGesture().onChanged { value in
                                let newValue =
                                    range.lowerBound
                                    + Int(
                                        value.location.x / geometry.size.width
                                            * CGFloat(
                                                range.upperBound
                                                    - range.lowerBound))
                                lowerValue = min(
                                    max(newValue, range.lowerBound),
                                    upperValue - 1)
                            }
                        )

                    // Upper thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 2)
                        .offset(
                            x: CGFloat(upperValue - range.lowerBound)
                                / CGFloat(range.upperBound - range.lowerBound)
                                * geometry.size.width - thumbSize / 2
                        )
                        .gesture(
                            DragGesture().onChanged { value in
                                let newValue =
                                    range.lowerBound
                                    + Int(
                                        value.location.x / geometry.size.width
                                            * CGFloat(
                                                range.upperBound
                                                    - range.lowerBound))
                                upperValue = max(
                                    min(newValue, range.upperBound),
                                    lowerValue + 1)
                            }
                        )
                }
            }
            .frame(height: thumbSize)
        }
    }
}
