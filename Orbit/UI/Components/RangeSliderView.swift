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

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                Rectangle()
                    .fill(Color.blue)
                    .frame(
                        width: CGFloat(upperValue - lowerValue)
                            / CGFloat(range.upperBound - range.lowerBound)
                            * geometry.size.width
                    )
                    .offset(
                        x: CGFloat(lowerValue - range.lowerBound)
                            / CGFloat(range.upperBound - range.lowerBound)
                            * geometry.size.width)

                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(radius: 4)
                        .offset(
                            x: CGFloat(lowerValue - range.lowerBound)
                                / CGFloat(range.upperBound - range.lowerBound)
                                * geometry.size.width
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
                            })

                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(radius: 4)
                        .offset(
                            x: CGFloat(upperValue - range.lowerBound)
                                / CGFloat(range.upperBound - range.lowerBound)
                                * geometry.size.width - 28
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
                            })
                }
            }
            .frame(height: 44)
        }
    }
}
