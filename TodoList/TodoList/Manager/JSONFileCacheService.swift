//
//  JSONFileCacheService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/12/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

enum FileCacheServiceLoadError: Error {
    case unknown
}

enum FileCacheServiceSaveError: Error {
    case unknown
}

final class JSONFileCacheService: FileCacheService {
    var items: [TodoItem] {
        get {
            self.fileCache.items
        }
        set {
            self.fileCache.items = newValue
        }
    }
    var revision: Int32 {
        get {
            self.fileCache.revision
        }
        set {
            print("\(newValue)")
            self.fileCache.revision = newValue
        }
    }

    private let fileCache: FileCache

    init() {
        self.fileCache = FileCache()
    }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().async {
            self.fileCache.save(to: file)
            DispatchQueue.main.async {
                completion(.success(()))
//                completion(.failure(FileCacheServiceSaveError.unknown))
            }
        }
    }

    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async {
            self.fileCache.load(from: file)
            DispatchQueue.main.async {
                completion(.success(self.fileCache.items))
//                completion(.failure(FileCacheServiceLoadError.unknown))
            }
        }
    }

    func add(_ newItem: TodoItem) {
        if self.fileCache.items.contains(where: { $0.id == newItem.id }) { return }
        self.fileCache.items.append(newItem)
    }

    func delete(id: String) {
        self.fileCache.items.removeAll { $0.id == id }
    }

    func modify(_ item: TodoItem) {
        for (index, value) in self.fileCache.items.enumerated() where value.id == item.id {
            self.fileCache.items[index] = item
        }
    }
}
