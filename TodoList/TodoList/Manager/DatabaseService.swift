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
    var items: [TodoItem] { get set }
    func add(_ item: TodoItem) -> Result<Void, Error>
    func delete(id: String) -> Result<Void, Error>
    func modify(_ item: TodoItem) -> Result<Void, Error>
    func save() -> Result<Void, Error>
    func load() -> Result<Void, Error>
}
