//
//  TodoItem.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

enum Importance: String {
    case high = "high"
    case medium = "medium"
    case low = "low"
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let modifiedAt: Date?

    init(id: String = UUID().uuidString, text: String, importance: Importance = .medium, deadline: Date? = nil, isDone: Bool = false, createdAt: Date = Date(), modifiedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
