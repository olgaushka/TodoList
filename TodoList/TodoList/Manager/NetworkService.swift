//
//  NetworkService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/13/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

struct NetworkTodoItemsListRequest: Encodable {
    var list: [NetworkTodoItem]
}

struct NetworkTodoItemsListResponse: Decodable {
    var list: [NetworkTodoItem]
    var revision: Int32
}

struct NetworkTodoItemRequest: Encodable {
    var element: NetworkTodoItem
}

struct NetworkTodoItemResponse: Decodable {
    var element: NetworkTodoItem
    var revision: Int32
}

enum NetworkServiceError: Error {
    case invalidURL
    case decoding(Error)
    case encoding(Error)
    case dataTask

    case badRequest
    case unsynchronizedData
    case unauthorized
    case notFound
    case server

    case unknown
}

protocol NetworkService {
    func getAllTodoItemsWithRequest(
        completion: @escaping (Result<NetworkTodoItemsListResponse, NetworkServiceError>) -> Void
    )
    func sendAllTodoItemsWithRequest(
        _ request: NetworkTodoItemsListRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemsListResponse, NetworkServiceError>) -> Void
    )
    func getTodoItem(
        at id: String,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    )
    func createTodoItemWithRequest(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    )
    func editTodoItemWithRequest(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    )
    func deleteTodoItem(
        id: String,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    )
}
