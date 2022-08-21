//
//  NetworkTodoItem.swift
//  TodoList
//
//  Created by Olga Zorina on 8/16/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

enum NetworkImportance: String, Codable {
    case high = "important"
    case medium = "basic"
    case low = "low"
}

struct NetworkTodoItem: Codable {
    let id: String
    let text: String
    let importance: NetworkImportance
    let deadline: Int64?
    let done: Bool
    let color: String
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    init(_ item: TodoItem) {
        self.id = item.id
        self.text = item.text
        switch item.importance {
        case .low:
            self.importance = .low
        case .medium:
            self.importance = .medium
        case .high:
            self.importance = .high
        }
        if let deadline = item.deadline?.timeIntervalSince1970 {
            self.deadline = Int64(deadline)
        } else {
            self.deadline = nil
        }
        self.done = item.isDone
        self.createdAt = Int64(item.createdAt.timeIntervalSince1970)
        if let changedAt = item.modifiedAt?.timeIntervalSince1970 {
            self.changedAt = Int64(changedAt)
        } else {
            self.changedAt = self.createdAt
        }
        self.lastUpdatedBy = "1"
        self.color = "#FFFFFF"
    }
}
