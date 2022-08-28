//
//  TodoItem.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

// rawValue is a part of storage model format
// swiftlint:disable redundant_string_enum_value
public enum Importance: String {
    case high = "high"
    case medium = "medium"
    case low = "low"
}
// swiftlint:enable redundant_string_enum_value

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadline: Date?
    public let isDone: Bool
    public let createdAt: Date
    public let modifiedAt: Date?

    public init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance = .medium,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

extension TodoItem {
    public func toggleCompleted() -> TodoItem {
        TodoItem(
            id: self.id,
            text: self.text,
            importance: self.importance,
            deadline: self.deadline,
            isDone: !self.isDone,
            createdAt: self.createdAt,
            modifiedAt: Date()
        )
  }
}
