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
import CocoaLumberjack

enum DatabaseError: Error {
    case wrongPath
    case alreadyExist
    case notExist
}

final class DefaultDatabaseService: DatabaseService {
    static let id = 1
    private(set) var items: [TodoItem]
    private var _revision: Int32
    var revision: Int32 {
        get {
            return _revision
        }
        set {
            self._revision = newValue
            do {
                try self.dbQueue.write { database in
                    try database.execute(
                        literal: "INSERT OR REPLACE INTO revision (id, revision) VALUES (\(Self.id), \(newValue))"
                    )
                }
            } catch {
                print(error)
                // Handle Error
            }
        }
    }
    private let dbQueue: DatabaseQueue

    private var completionQueue: DispatchQueue {
        return .main
    }

    private init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
        self._revision = 0
        self.items = []

        do {
            let rowOptional = try self.dbQueue.read { database in
                try Row.fetchOne(database, sql: "SELECT * FROM revision WHERE id = ?", arguments: [Self.id])
            }
            if let row = rowOptional {
                self.revision = row["revision"]
            }
        } catch {
            DDLogError("Could not fetch revision. Error: \(error)")
        }
    }

    static func make(dbName: String) -> Result<DefaultDatabaseService, Error> {
        let databaseQueueResult = self.loadDatabase(dbName)
        let databaseServiceResult = databaseQueueResult.map { databaseQueue -> DefaultDatabaseService in
            let databaseService = Self.init(dbQueue: databaseQueue)     // swiftlint:disable:this explicit_init
            return databaseService
        }
        return databaseServiceResult
    }

    func add(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        if self.items.contains(where: { $0.id == item.id }) {
            self.completionQueue.async {
                completion(.failure(DatabaseError.alreadyExist))
            }
            return
        }
        self.items.append(item)

        self.dbQueue.asyncWrite { database in
            try DatabaseTodoItem(item).insert(database)
        } completion: { _, result in
            self.completionQueue.async {
                completion(result)
            }
        }
    }

    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.items.removeAll { $0.id == id }
        self.dbQueue.asyncWrite { database -> Void in
            try DatabaseTodoItem.deleteOne(database, key: id)
        } completion: { _, result in
            self.completionQueue.async {
                completion(result)
            }
        }
    }

    func modify(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = self.items.firstIndex(where: { $0.id == item.id }) {
            self.items[index] = item
            let databaseTodoItem = DatabaseTodoItem(item)

            self.dbQueue.asyncWrite { database in
                try databaseTodoItem.update(database)
            } completion: { _, result in
                self.completionQueue.async {
                    completion(result)
                }
            }
        } else {
            self.completionQueue.async {
                completion(.failure(DatabaseError.notExist))
            }
        }
    }

    func save(_ items: [TodoItem], revision: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
        self._revision = revision
        self.items = items

        self.dbQueue.asyncWrite { database in
            try DatabaseTodoItem.deleteAll(database)
            for item in items {
                try DatabaseTodoItem(item).insert(database)
            }

            try database.execute(
                literal: "INSERT OR REPLACE INTO revision (id, revision) VALUES (\(Self.id), \(revision))"
            )
        } completion: { _, result in
            self.completionQueue.async {
                completion(result)
            }
        }
    }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        self.dbQueue.asyncRead { dbResult in
            do {
                let database = try dbResult.get()
                let databaseItems = try DatabaseTodoItem.fetchAll(database)
                self.items = databaseItems.map { item in
                    DatabaseTodoItem.makeItem(item)
                }
                self.completionQueue.async {
                    completion(.success(()))
                }
            } catch {
                self.completionQueue.async {
                    completion(.failure(error))
                }
            }
        }
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
                }
            }
            return .success(dbQueue)
        } catch {
            return .failure(error)
        }
    }
}
