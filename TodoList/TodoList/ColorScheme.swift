//
//  ColorScheme.swift
//  TodoList
//
//  Created by Olga Zorina on 8/10/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class ColorScheme {
    static let shared: ColorScheme = ColorScheme()

//    let backPrimary: UIColor = .init(red: 0.97, green: 0.966, blue: 0.951, alpha: 1)

    let backPrimary: UIColor = color(
        light: .init(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0),
        dark: .init(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
    )

    let backSecondary: UIColor = color(
        light: .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        dark: .init(red: 0.14, green: 0.14, blue: 0.16, alpha: 1.0)
    )

    let labelPrimary: UIColor = color(
        light: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        dark: .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )

    let labelTertiary: UIColor = color(
        light: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
        dark: .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
    )

    let separator: UIColor = color(
        light: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2),
        dark: .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    )

    let blue: UIColor = color(
        light: .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),
        dark: .init(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)
    )

    let green: UIColor = color(
        light: .init(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0),
        dark: .init(red: 0.2, green: 0.84, blue: 0.29, alpha: 1.0)
    )

    let grayLight: UIColor = color(
        light: .init(red: 0.82, green: 0.82, blue: 0.839, alpha: 1.0),
        dark: .init(red: 0.28, green: 0.28, blue: 0.29, alpha: 1.0)
    )

    let red: UIColor = color(
        light: .init(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0),
        dark: .init(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0)
    )

    private init() {
    }

    private static func color(light: UIColor, dark: UIColor) -> UIColor {
        return .init { traitCollection -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .unspecified, .light:
                return light
            case .dark:
                return dark
            @unknown default:
                return light
            }
        }
    }
}
