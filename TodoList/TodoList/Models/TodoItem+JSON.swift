//
//  TodoItem+JSON.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

extension TodoItem {
    var json: Any {
        let formatter = ISO8601DateFormatter()
        let createdAt: String = formatter.string(from: self.createdAt)

        var result:[String: Any] = ["id": self.id, "text": self.text, "isDone": self.isDone, "createdAt": createdAt]

        if self.importance != .medium {
            result["importance"] = self.importance.rawValue
        }

        if let deadline = self.deadline {
            result["deadline"] = formatter.string(from: deadline)
        }

        if let modifiedAt = self.modifiedAt {
            result["modifiedAt"] = formatter.string(from: modifiedAt)
        }
        return result
    }

    static func parse(json: Any) -> TodoItem? {
        guard let jsonObject = json as? [String: Any],
              let id = jsonObject["id"] as? String,
              let text = jsonObject["text"] as? String,
              let isDone = jsonObject["isDone"] as? Bool,
              let createdAtString = jsonObject["createdAt"] as? String else { return nil }

        let formatter = ISO8601DateFormatter()
        guard let createdAt = formatter.date(from: createdAtString) else { return nil }

        let importance: Importance
        let modifiedAt: Date?
        let deadline: Date?
        if let rawImportance = jsonObject["importance"] {
            guard let importanceString = rawImportance as? String, let importanceValue = Importance(rawValue: importanceString) else { return nil }
            importance = importanceValue
        } else {
            importance = .medium
        }

        if let rawDeadline = jsonObject["deadline"] {
            guard let deadlineString = rawDeadline as? String, let deadlineDate = formatter.date(from: deadlineString) else { return nil }
            deadline = deadlineDate
        } else {
            deadline = nil
        }

        if let rawModifiedAt = jsonObject["modifiedAt"] {
            guard let modifiedAtString = rawModifiedAt as? String, let modifiedAtDate = formatter.date(from: modifiedAtString) else { return nil }
            modifiedAt = modifiedAtDate
        } else {
            modifiedAt = nil
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, modifiedAt: modifiedAt)
    }
}
