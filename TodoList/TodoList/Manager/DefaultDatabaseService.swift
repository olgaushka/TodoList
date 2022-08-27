//
//  DefaultDatabaseService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/23/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels
import GRDB

final class DefaultDatabaseService: DatabaseService {
    static let id = 1
    var items: [TodoItem]
    var revision: Int32 {
        didSet {
            do {
                try self.dbQueue.write { database in
                    let revision = self.revision
                    try database.execute(
                        literal: "INSERT OR REPLACE INTO revision (id, revision) VALUES (\(Self.id), \(revision))"
                    )
                }
            } catch {
                print(error)
                // Handle Error
            }
        }
    }
    private let dbQueue: DatabaseQueue

    private init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
        self.revision = 0
        self.items = []

        do {
            let rowOptional = try self.dbQueue.read { database in
                try Row.fetchOne(database, sql: "SELECT * FROM revision WHERE id = \(Self.id)")
            }
            if let row = rowOptional {
                self.revision = row["revision"]
            }
            print("REVISION \(self.revision)")
        } catch {
            print(error)
            // Handle Error
        }
    }

    static func make(dbName: String) -> Result<DefaultDatabaseService, Error> {
        let databaseQueueResult = self.loadDatabase(dbName)
        let databaseServiceResult = databaseQueueResult.map { databaseQueue -> DefaultDatabaseService in
            let databaseService = Self.init(dbQueue: databaseQueue)
            return databaseService
        }
        return databaseServiceResult
    }

    func add(item: TodoItem) {
        if self.items.contains(where: { $0.id == item.id }) { return }
        self.items.append(item)

        do {
            try self.dbQueue.write { database in
                try DatabaseTodoItem(item).insert(database)
            }
        } catch {
            print(error)
            // Handle Error
        }
    }

    func removeBy(id: String) {
        self.items.removeAll { $0.id == id }

        do {
            _ = try self.dbQueue.write { database in
                try DatabaseTodoItem.deleteOne(database, key: id)
            }
        } catch {
            print(error)
            // Handle Error
        }
    }

    func modify(item: TodoItem) {
        for (index, value) in self.items.enumerated() where value.id == item.id {
            self.items[index] = item
            let databaseTodoItem = DatabaseTodoItem(item)

            do {
                try dbQueue.write { database in
                    try databaseTodoItem.update(database)
                }
            } catch {
                print(error)
                // Handle Error
            }
        }
    }

    func save() {
        do {
            try self.dbQueue.write { database in
                try DatabaseTodoItem.deleteAll(database)
                for item in self.items {
                    try DatabaseTodoItem(item).insert(database)
                }
            }
        } catch {
            print(error)
            // Handle Error
        }
    }

    func load() {
        do {
            let databaseItems = try self.dbQueue.read { database in
                try DatabaseTodoItem.fetchAll(database)
            }
            self.items = databaseItems.map { item in
                DatabaseTodoItem.makeItem(item)
            }
        } catch {
            print(error)
            // Handle Error
        }
    }

    enum DatabaseError: Error {
        case wrongPath
    }

    private static func loadDatabase(_ dbName: String) -> Result<DatabaseQueue, Error> {
        let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        guard let libraryDirectoryPath = path else { return .failure(DatabaseError.wrongPath) }

        let dbURL = libraryDirectoryPath.appendingPathComponent(dbName)

        do {
            let dbQueue = try DatabaseQueue(path: dbURL.absoluteString)

            try dbQueue.write { database in
                try database.create(table: "Item", options: .ifNotExists) { table in
                    table.primaryKey(["id"])
                    table.column("id", .text).notNull()
                    table.column("text", .text).notNull()
                    table.column("importance", .text).notNull()
                    table.column("deadline", .datetime)
                    table.column("isDone", .boolean).notNull()
                    table.column("createdAt", .datetime).notNull()
                    table.column("modifiedAt", .datetime)
                }
                try database.create(table: "Revision", options: .ifNotExists) { table in
                    table.autoIncrementedPrimaryKey("id").check { $0 == Self.id }
                    table.column("revision", .integer).notNull()
                    print("\(table)")
                }
            }
            return .success(dbQueue)
        } catch {
            print(error)
            return .failure(error)
            // Handle Error
        }
    }
}
