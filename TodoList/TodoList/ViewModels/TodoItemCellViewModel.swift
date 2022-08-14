//
//  TodoItemCellViewModel.swift
//  TodoList
//
//  Created by Olga Zorina on 8/6/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

final class TodoItemCellViewModel {
    let id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var isDone: Bool

    var didTapDone: (() -> Void)?

    init(id: String, text: String, importance: Importance = .medium, deadline: Date? = nil, isDone: Bool = false) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
    }

    static func makeDefault() -> TodoItemCellViewModel {
        let viewModel = TodoItemCellViewModel(id: "", text: "")
        return viewModel
    }
}
