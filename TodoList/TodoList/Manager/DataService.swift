//
//  DataService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/20/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels
import CocoaLumberjack

final class DataService {
    let fileCacheService: FileCacheService
    let networkService: NetworkService
    let databaseService: DatabaseService
    let fileName: String

    var dataIsDirty: Bool {
        didSet(newValue) {
            print("\(newValue)")
        }
    }
    var items: [TodoItem] {
        self.databaseService.items
    }

    init(
        fileCacheService: FileCacheService,
        fileName: String,
        networkService: NetworkService,
        databaseService: DatabaseService
    ) {
        self.fileName = fileName
        self.fileCacheService = fileCacheService
        self.networkService = networkService
        self.databaseService = databaseService
        self.dataIsDirty = false
    }

    func getCachedData(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let result = self.databaseService.load()
        switch result {
        case .success:
            completion(.success(self.databaseService.items))
        case let .failure(error):
            completion(.failure(error))
        }
    }

    func loadData(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        self.networkService.getAllTodoItemsWithRequest { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                if self.databaseService.revision != response.revision {
                    DDLogInfo("dataIsDirty = true  loadData")
                    self.dataIsDirty = true
                    self.synchronizeData(completion: completion)
                } else {
                    completion(.success(self.databaseService.items))
                }
            case let .failure(error):
                DDLogError(error)
                self.dataIsDirty = true
                completion(.failure(error))
            }
        }
    }

    func add(_ newItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let result = self.databaseService.add(newItem)
        if case let .failure(error) = result {
            completion(.failure(error))
        }

        if self.dataIsDirty {
            self.synchronizeData { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            return
        }

        let networkItem = NetworkTodoItem(newItem)
        let elementRequest = NetworkTodoItemRequest(element: networkItem)

        self.networkService.createTodoItemWithRequest(
            elementRequest,
            revision: self.databaseService.revision
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                let item = TodoItem(networkItem: response.element)
                _ = self.databaseService.modify(item)
                self.databaseService.revision = response.revision
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  add")
                completion(.failure(error))
            }
        }
    }

    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let result = self.databaseService.delete(id: id)
        if case let .failure(error) = result {
            completion(.failure(error))
        }

        if self.dataIsDirty {
            self.synchronizeData { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            return
        }

        self.networkService.deleteTodoItem(id: id, revision: self.databaseService.revision) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                self.databaseService.revision = response.revision
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  delete")
                completion(.failure(error))
            }
        }
    }

    func modify(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let result = self.databaseService.modify(item)
        if case let .failure(error) = result {
            completion(.failure(error))
        }

        if self.dataIsDirty {
            self.synchronizeData { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            return
        }

        let networkItem = NetworkTodoItem(item)
        let elementRequest = NetworkTodoItemRequest(element: networkItem)

        self.networkService.editTodoItemWithRequest(
            elementRequest,
            revision: self.databaseService.revision
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                let item = TodoItem(networkItem: response.element)
                _ = self.databaseService.modify(item)
                self.databaseService.revision = response.revision
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  modify")
                completion(.failure(error))
            }
        }
    }

    private func synchronizeData(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let networkItems = self.databaseService.items.map { item -> NetworkTodoItem in
            return NetworkTodoItem(item)
        }
        let listRequest = NetworkTodoItemsListRequest(list: networkItems)
        self.networkService.sendAllTodoItemsWithRequest(
            listRequest,
            revision: self.databaseService.revision
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                self.databaseService.items = response.list.map { TodoItem(networkItem: $0) }
                self.databaseService.revision = response.revision
                self.dataIsDirty = false
                _ = self.databaseService.save()
                DDLogInfo("SYNCHRONIZATION")
                completion(.success(self.databaseService.items))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
