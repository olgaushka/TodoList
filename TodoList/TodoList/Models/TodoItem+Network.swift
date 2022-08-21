//
//  TodoItem+Network.swift
//  TodoList
//
//  Created by Olga Zorina on 8/16/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

extension TodoItem {
    init(networkItem: NetworkTodoItem) {
        let id = networkItem.id
        let text = networkItem.text
        let importance: Importance
        switch networkItem.importance {
        case .low:
            importance = .low
        case .medium:
            importance = .medium
        case .high:
            importance = .high
        }
        let deadline: Date?
        if let deadlineInt64 = networkItem.deadline {
            deadline = Date(timeIntervalSince1970: Double(deadlineInt64))
        } else {
            deadline = nil
        }
        let isDone = networkItem.done
        let createdAt = Date(timeIntervalSince1970: Double(networkItem.createdAt))
        let modifiedAt = Date(timeIntervalSince1970: Double(networkItem.changedAt))

        self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
}
