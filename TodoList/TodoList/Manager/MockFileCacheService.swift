//
//  MockFileCacheService.swift
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

final class MockFileCacheService: FileCacheService {
    private(set) var items: [TodoItem] = []
    private let fileCache: FileCache = {
        let fileCache = FileCache()
        return fileCache
    }()

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().async {
            let timeout = TimeInterval.random(in: 1..<3)
            self.fileCache.items = self.items
            self.fileCache.save(to: file)
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                completion(.success(()))
//                completion(.failure(FileCacheServiceSaveError.unknown))
            }
        }
    }

    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async {
            let timeout = TimeInterval.random(in: 1..<3)
            self.fileCache.load(from: file)
            self.items = self.fileCache.items
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                completion(.success(self.items))
//                completion(.failure(FileCacheServiceLoadError.unknown))
            }
        }
    }

    func add(_ newItem: TodoItem) {
        if self.items.contains(where: { $0.id == newItem.id }) { return }
        self.items.append(newItem)
    }

    func delete(id: String) {
        self.items.removeAll { $0.id == id }
    }

    func modify(_ item: TodoItem) {
        for (index, value) in self.items.enumerated() where value.id == item.id {
            self.items[index] = item
        }
    }
}
