//
//  NetworkService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/13/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

protocol NetworkService {
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func sendAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func getTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func createTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
}
