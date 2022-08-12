//
//  FileCacheService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/12/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

protocol FileCacheService {
    var items: [TodoItem] { get }
    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void)
    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func add(_ newItem: TodoItem)
    func delete(id: String)
    func modify(_ item: TodoItem)
}
