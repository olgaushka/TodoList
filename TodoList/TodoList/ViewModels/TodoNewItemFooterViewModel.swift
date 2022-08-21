//
//  TodoNewItemFooterViewModel.swift
//  TodoList
//
//  Created by Olga Zorina on 8/7/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

final class TodoNewItemFooterViewModel {
    var text: String
    var isSeparatorHidden: Bool

    var didTapDone: (() -> Void)?

    init(text: String, isSeparatorHidden: Bool) {
        self.isSeparatorHidden = isSeparatorHidden
        self.text = text
    }

    static func makeDefault() -> TodoNewItemFooterViewModel {
        let viewModel = TodoNewItemFooterViewModel(text: "", isSeparatorHidden: true)
        return viewModel
    }
}
