//
//  DatabaseTodoItem.swift
//  TodoList
//
//  Created by Olga Zorina on 8/23/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels
import GRDB

extension Importance: Codable {
}

struct DatabaseTodoItem: Codable, FetchableRecord, PersistableRecord {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let modifiedAt: Date?

    init(_ item: TodoItem) {
        self.id = item.id
        self.text = item.text
        self.importance = item.importance
        self.deadline = item.deadline
        self.isDone = item.isDone
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
    }

    static var databaseTableName: String {
        return "Item"
    }

    static func makeItem(_ dbItem: DatabaseTodoItem) -> TodoItem {
        return TodoItem(
            id: dbItem.id,
            text: dbItem.text,
            importance: dbItem.importance,
            deadline: dbItem.deadline,
            isDone: dbItem.isDone,
            createdAt: dbItem.createdAt,
            modifiedAt: dbItem.modifiedAt
        )
    }
}
