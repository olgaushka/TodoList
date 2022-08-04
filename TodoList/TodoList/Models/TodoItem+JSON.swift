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
        guard let jsonObject = json as? [String: Any] else { return nil }
        guard let rawId = jsonObject["id"], let id = rawId as? String else { return nil }
        guard let rawText = jsonObject["text"], let text = rawText as? String else { return nil }
        guard let rawIsDone = jsonObject["isDone"], let isDone = rawIsDone as? Bool else { return nil }
        guard let rawCreatedAt = jsonObject["createdAt"], let createdAtString = rawCreatedAt as? String else { return nil }

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
            guard let deadlineString = rawDeadline as? String else { return nil }
            deadline = formatter.date(from: deadlineString)
        } else {
            deadline = nil
        }

        if let rawModifiedAt = jsonObject["modifiedAt"] {
            guard let modifiedAtString = rawModifiedAt as? String else { return nil }
            modifiedAt = formatter.date(from: modifiedAtString)
        } else {
            modifiedAt = nil
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, modifiedAt: modifiedAt)
    }
}
