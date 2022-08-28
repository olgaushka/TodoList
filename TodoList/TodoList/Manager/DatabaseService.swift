//
//  DatabaseService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/24/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

protocol DatabaseService: AnyObject {
    var revision: Int32 { get set }
    var items: [TodoItem] { get }
    func add(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func modify(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func load(completion: @escaping (Result<Void, Error>) -> Void)
    func save(_ items: [TodoItem], revision: Int32, completion: @escaping (Result<Void, Error>) -> Void)
}
