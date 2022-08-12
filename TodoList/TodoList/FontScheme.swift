//
//  FontScheme.swift
//  TodoList
//
//  Created by Olga Zorina on 8/10/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class FontScheme {
    static let shared: FontScheme = .init()

    let body: UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    let subhead: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    let subheadline: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    let footnote: UIFont = UIFont.systemFont(ofSize: 13, weight: .semibold)

    private init() {
    }
}
