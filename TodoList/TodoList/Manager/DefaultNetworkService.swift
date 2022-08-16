//
//  DefaultNetworkService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/16/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

final class DefaultNetworkService: NetworkService {
    private let baseURL = "https://beta.mrdekk.ru/todobackend"
    private let list = "list"
    private var networkItems = [NetworkTodoItem]()
    private var revision: Int32 = 0

    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL) else {
            return
        }

        var request = URLRequest(url: listURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "Bearer EnchantingVoicelessSpellcasting"]

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    self.networkItems = try decoder.decode([NetworkTodoItem].self, from: data)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func sendAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL) else {
            return
        }

        var request = URLRequest(url: listURL)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = [ "Authorization": "Bearer EnchantingVoicelessSpellcasting",
                                        "X-Last-Known-Revision": "\(self.revision)" ]

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    self.networkItems = try decoder.decode([NetworkTodoItem].self, from: data)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func getTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL),
              let itemURL = URL(string: id, relativeTo: listURL) else {
            return
        }

        var request = URLRequest(url: itemURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [ "Authorization": "Bearer EnchantingVoicelessSpellcasting" ]


        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    let networkItem = try decoder.decode(NetworkTodoItem.self, from: data)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func createTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL) else {
            return
        }

        var request = URLRequest(url: listURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [ "Authorization": "Bearer EnchantingVoicelessSpellcasting",
                                       "X-Last-Known-Revision": "\(self.revision)" ]


        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    let networkItem = try decoder.decode(NetworkTodoItem.self, from: data)
                    self.networkItems.append(networkItem)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL),
              let itemURL = URL(string: item.id, relativeTo: listURL) else {
            return
        }

        var request = URLRequest(url: itemURL)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [ "Authorization": "Bearer EnchantingVoicelessSpellcasting",
                                        "X-Last-Known-Revision": "\(self.revision)" ]

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    let networkItem = try decoder.decode(NetworkTodoItem.self, from: data)
                    self.networkItems.append(networkItem)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let baseURL = URL(string: baseURL),
              let listURL = URL(string: list, relativeTo: baseURL),
              let itemURL = URL(string: id, relativeTo: listURL) else {
            return
        }

        var request = URLRequest(url: itemURL)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [ "Authorization": "Bearer EnchantingVoicelessSpellcasting",
                                        "X-Last-Known-Revision": "\(self.revision)" ]

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(data, response, error)
                    let networkItem = try decoder.decode(NetworkTodoItem.self, from: data)
                    self.networkItems.append(networkItem)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
}
