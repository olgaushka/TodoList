//
//  TodoItemScrollViewModel.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

final class TodoItemScrollViewModel {
    var text: String
    var importance: Importance
    var deadline: Date?

    var didTapDelete: (() -> Void)?

    init(text: String, importance: Importance, deadline: Date? = nil) {
        self.text = text
        self.importance = importance
        self.deadline = deadline
    }

    static func makeDefault() -> TodoItemScrollViewModel{
        let viewModel = TodoItemScrollViewModel(text: "", importance: Importance.medium)
        return viewModel
    }
}
