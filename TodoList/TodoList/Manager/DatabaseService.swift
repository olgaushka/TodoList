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
    func add(item: TodoItem)
    func removeBy(id: String)
    func modify(item: TodoItem)
    func save()
    func load()
}
