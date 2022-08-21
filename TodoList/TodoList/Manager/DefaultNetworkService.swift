//
//  DefaultNetworkService.swift
//  TodoList
//
//  Created by Olga Zorina on 8/16/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import TodoListModels
import CocoaLumberjack

// swiftlint:disable:next type_body_length
final class DefaultNetworkService: NetworkService {
    private let baseURL = "https://beta.mrdekk.ru"
    private let list = "/todobackend/list"
    private var accessToken: String = "EnchantingVoicelessSpellcasting"
    private let urlSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }()
    private var retryQueue: DispatchQueue {
        return self.urlSession.delegateQueue.underlyingQueue ?? .main
    }
    private var completionQueue: DispatchQueue {
        return .main
    }

    func getAllTodoItemsWithRequest(
        completion: @escaping (Result<NetworkTodoItemsListResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.requestForList(httpMethod: "GET")
        switch requestResult {
        case let .success(request):
            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemsListResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case .failure:
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    func sendAllTodoItemsWithRequest(
        _ request: NetworkTodoItemsListRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemsListResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.requestForListPatch(request, revision: revision, httpMethod: "PATCH")
        switch requestResult {
        case let .success(request):
            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemsListResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case .failure:
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    func getTodoItem(
        at id: String,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.requestForItemWithIdentifier(id, httpMethod: "GET")

        switch requestResult {
        case let .success(request):
            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case .failure:
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    func createTodoItemWithRequest(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.requestForElementCreate(request, revision: revision, httpMethod: "POST")
        switch requestResult {
        case let .success(request):

            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case let .failure(error):
                    DDLogError(error)
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    func editTodoItemWithRequest(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.request(request, revision: revision, httpMethod: "PUT")
        switch requestResult {
        case let .success(request):
            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case .failure:
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    func deleteTodoItem(
        id: String,
        revision: Int32,
        completion: @escaping (Result<NetworkTodoItemResponse, NetworkServiceError>) -> Void
    ) {
        let requestResult = self.requestForItemWithIdentifier(id, revision: revision, httpMethod: "DELETE")
        switch requestResult {
        case let .success(request):
            self.dataTask(with: request) { [weak self] result in
                switch result {
                case let .success(responsePair):
                    let responseResult = Self.response(type: NetworkTodoItemResponse.self, from: responsePair)
                    self?.completionQueue.async {
                        completion(responseResult)
                    }
                case .failure:
                    self?.completionQueue.async {
                        completion(.failure(.dataTask))
                    }
                }
            }

        case let .failure(error):
            self.completionQueue.async {
                completion(.failure(error))
            }
        }
    }

    private func request(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        httpMethod: String
    ) -> Result<URLRequest, NetworkServiceError> {
        let result = requestForItemWithIdentifier(request.element.id, revision: revision, httpMethod: httpMethod)
        switch result {
        case .success(var urlRequest):
            let encoder = JSONEncoder()
            do {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try encoder.encode(request)
            } catch {
                return .failure(.encoding(error))
            }
            return .success(urlRequest)

        case let .failure(error):
            return .failure(error)
        }
    }

    private func requestForItemWithIdentifier(
        _ identifier: String,
        revision: Int32,
        httpMethod: String
    ) -> Result<URLRequest, NetworkServiceError> {
        let requestResult = self.requestForItemWithIdentifier(identifier, httpMethod: httpMethod)
        let result: Result<URLRequest, NetworkServiceError>
        switch requestResult {
        case .success(var urlRequest):
            urlRequest.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
            result = .success(urlRequest)

        case let .failure(error):
            result = .failure(error)
        }
        return result
    }

    private func requestForItemWithIdentifier(
        _ identifier: String,
        httpMethod: String
    ) -> Result<URLRequest, NetworkServiceError> {
        guard var components = URLComponents(string: baseURL) else {
            return .failure(NetworkServiceError.invalidURL)
        }
        guard let encodedId = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(NetworkServiceError.invalidURL)
        }
        components.path = list + "/\(encodedId)"
        guard let itemURL = components.url else {
            return .failure(NetworkServiceError.invalidURL)
        }

        var urlRequest = URLRequest(url: itemURL)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return .success(urlRequest)
    }

    private func requestForElementCreate(
        _ request: NetworkTodoItemRequest,
        revision: Int32,
        httpMethod: String
    ) -> Result<URLRequest, NetworkServiceError> {
        let result = requestForList(httpMethod: httpMethod)
        switch result {
        case .success(var urlRequest):
            urlRequest.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")

            let encoder = JSONEncoder()
            do {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try encoder.encode(request)
            } catch {
                return .failure(.encoding(error))
            }
            return .success(urlRequest)

        case let .failure(error):
            return .failure(error)
        }
    }

    private func requestForListPatch(
        _ request: NetworkTodoItemsListRequest,
        revision: Int32,
        httpMethod: String
    ) -> Result<URLRequest, NetworkServiceError> {
        let result = requestForList(httpMethod: httpMethod)
        switch result {
        case .success(var urlRequest):
            urlRequest.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")

            let encoder = JSONEncoder()
            do {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try encoder.encode(request)
            } catch {
                return .failure(.encoding(error))
            }
            return .success(urlRequest)

        case let .failure(error):
            return .failure(error)
        }
    }

    private func requestForList(httpMethod: String) -> Result<URLRequest, NetworkServiceError> {
        guard var components = URLComponents(string: baseURL) else {
            return .failure(NetworkServiceError.invalidURL)
        }
        components.path = list
        guard let listURL = components.url else {
            return .failure(NetworkServiceError.invalidURL)
        }

        var urlRequest = URLRequest(url: listURL)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return .success(urlRequest)
    }

    private static func response<T: Decodable>(
        type: T.Type,
        from responsePair: (Data, HTTPURLResponse)
    ) -> Result<T, NetworkServiceError> {
        let (data, response) = responsePair

        switch response.statusCode {
        case 400:
            if let str = String(data: data, encoding: .utf8), str == "unsynchronized data" {
                return .failure(.unsynchronizedData)
            } else {
                return .failure(.badRequest)
            }
        case 401:
            return .failure(.unauthorized)
        case 404:
            return .failure(.notFound)
        case 500:
            return .failure(.server)
        case 200...299:
            let decoder = JSONDecoder()
            do {
                let item = try decoder.decode(T.self, from: data)
                return .success(item)
            } catch {
                return .failure(.decoding(error))
            }
        default:
            return .failure(.unknown)
        }
    }

    private enum DataTaskError: Error {
        case response(Error)
        case nonHTTPResponse
        case noData
    }

    private func dataTask(
        with request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), DataTaskError>) -> Void
    ) {
        self._retryableDataTask(with: request, completion: completion)
    }

    private func _dataTask(
        with request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), DataTaskError>) -> Void
    ) {
        let task = self.urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(.response(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.nonHTTPResponse))
                return
            }

            completion(.success((data, httpResponse)))
        }
        task.resume()
    }

    private func _retryableDataTask(
        with request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), DataTaskError>) -> Void
    ) {
        let minDelay: Double = 2
        self._retryableDataTask(with: request, delay: minDelay, completion: completion)
    }

    private func _retryableDataTask(
        with request: URLRequest,
        delay: TimeInterval,
        completion: @escaping (Result<(Data, HTTPURLResponse), DataTaskError>) -> Void
    ) {
        print("delay: \(delay)")

        let maxDelay: TimeInterval = 120
        let factor = 1.5
        let jitter = 0.05

        self._dataTask(with: request) { result in
            switch result {
            case let .success(pair):
                completion(.success(pair))

            case let .failure(error):
                switch error {
                case .noData, .nonHTTPResponse:
                    completion(.failure(error))

                case let .response(responseError):
                    if let urlError = responseError as? URLError {
                        switch urlError.code {
                        case .timedOut,
                             .cannotFindHost,
                             .cannotConnectToHost,
                             .networkConnectionLost,
                             .dnsLookupFailed,
                             .notConnectedToInternet,
                             .badServerResponse,
                             .cannotLoadFromNetwork,
                             .callIsActive:
                            let currentDelay = delay * factor * Double.random(in: (1.0 - jitter)...(1.0 + jitter))
                            if currentDelay <= maxDelay {
                                self.retryQueue.asyncAfter(deadline: .now() + currentDelay) {
                                    self._retryableDataTask(with: request, delay: currentDelay, completion: completion)
                                }
                            } else {
                                completion(.failure(.response(urlError)))
                            }

                        default:
                            completion(.failure(.response(urlError)))
                        }
                    } else {
                        completion(.failure(.response(responseError)))
                    }
                }
            }
        }
    }
}
