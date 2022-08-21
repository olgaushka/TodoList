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
    let fileName: String

    var dataIsDirty: Bool {
        didSet(newValue){
            print("\(newValue)")
        }
    }
    var items: [TodoItem] {
        self.fileCacheService.items
    }

    init(fileCacheService: FileCacheService, fileName: String, networkService: NetworkService) {
        self.fileName = fileName
        self.fileCacheService = fileCacheService
        self.networkService = networkService
        self.dataIsDirty = false
    }

    func loadData(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        self.fileCacheService.load(from: self.fileName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.networkService.getAllTodoItemsWithRequest { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case let .success(response):
                        if self.fileCacheService.revision != response.revision {
                            DDLogInfo("dataIsDirty = true  loadData")
                            self.dataIsDirty = true
                            self.synchronizeData(completion: completion)
                        } else {
                            completion(.success(self.fileCacheService.items))
                        }
                    case let .failure(error):
                        DDLogError(error)
                        completion(.success(self.fileCacheService.items))
                        self.dataIsDirty = true
//                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func add(_ newItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        self.fileCacheService.add(newItem)
        self.saveFileCacheData()

        if self.dataIsDirty {
            self.synchronizeData { [weak self] result in
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

        self.networkService.createTodoItemWithRequest(elementRequest, revision: self.fileCacheService.revision) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                let item = TodoItem(networkItem: response.element)
                self.fileCacheService.modify(item)
                self.fileCacheService.revision = response.revision
                self.saveFileCacheData()
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  add")
                completion(.failure(error))
            }
        }
    }

    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.fileCacheService.delete(id: id)
        self.saveFileCacheData()

        if self.dataIsDirty {
            self.synchronizeData { [weak self] result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            return
        }

        self.networkService.deleteTodoItem(id: id, revision: self.fileCacheService.revision) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                self.fileCacheService.revision = response.revision
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  delete")
                completion(.failure(error))
            }
        }
    }

    func modify(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        self.fileCacheService.modify(item)
        self.saveFileCacheData()

        if self.dataIsDirty {
            self.synchronizeData { [weak self] result in
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

        self.networkService.editTodoItemWithRequest(elementRequest, revision: self.fileCacheService.revision) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                let item = TodoItem(networkItem: response.element)
                self.fileCacheService.modify(item)
                self.fileCacheService.revision = response.revision
                self.saveFileCacheData()
                completion(.success(()))
            case let .failure(error):
                self.dataIsDirty = true
                DDLogInfo("dataIsDirty = true  modify")
                completion(.failure(error))
            }
        }
    }

    private func synchronizeData(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let networkItems = self.fileCacheService.items.map { item -> NetworkTodoItem in
            return NetworkTodoItem(item)
        }
        let listRequest = NetworkTodoItemsListRequest(list: networkItems)
        self.networkService.sendAllTodoItemsWithRequest(listRequest, revision: self.fileCacheService.revision) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                self.fileCacheService.items = response.list.map { TodoItem(networkItem: $0) }
                self.fileCacheService.revision = response.revision
                self.dataIsDirty = false
                self.saveFileCacheData()
                DDLogInfo("SYNCHRONIZATION")
                completion(.success(self.fileCacheService.items))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func saveFileCacheData() {
        self.fileCacheService.save(to: self.fileName) { _ in }
    }
}
