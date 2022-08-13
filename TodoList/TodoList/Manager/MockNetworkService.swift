//
//  MockNetworkService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/13/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

final class MockNetworkService: NetworkService {
    private(set) var items: [TodoItem] = [
        TodoItem(text: "Тестовое задание 1"),
        TodoItem(text: "Тестовое задание с длинным названием", importance: .low, deadline: Date(), isDone: false),
        TodoItem(text: "Тестовое задание 2", importance: .high, deadline: Date(), isDone: true),
    ]

    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async {
            let timeout = TimeInterval.random(in: 1..<3)
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                completion(.success(self.items))
            }
        }
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async {
            for (index, value) in self.items.enumerated() where value.id == item.id {
                self.items[index] = item
            }
            let timeout = TimeInterval.random(in: 1..<3)
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                completion(.success(item))
            }
        }
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async {
            if let index = self.items.firstIndex(where: { $0.id == id }) {
                let deletedItem = self.items.remove(at: index)
                let timeout = TimeInterval.random(in: 1..<3)
                DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                    completion(.success(deletedItem))
                }
            }
        }
    }
}
