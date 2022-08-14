//
//  TodoListTests.swift
//  TodoListTests
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import XCTest
@testable import TodoList
import TodoListModels

class TodoItemJSONTests: XCTestCase {
    func testParseDefault() {
        let jsonObject: [String: Any] = [
            "id": "123",
            "text": "Todo",
            "isDone": false,
            "createdAt": "2022-07-28T06:00:00Z",
        ]
        guard let item = TodoItem.parse(json: jsonObject) else {
            XCTFail("Invalid data passed: \(jsonObject)")
            return
        }

        let createdAt = Date(timeIntervalSince1970: 1658988000) // 2022.07.29 09:00:00 GMT+0300
        let expected = TodoItem(
            id: "123",
            text: "Todo",
            importance: .medium,
            deadline: nil,
            isDone: false,
            createdAt: createdAt,
            modifiedAt: nil
        )

        XCTAssertEqual(item.id, expected.id)
        XCTAssertEqual(item.text, expected.text)
        XCTAssertEqual(item.importance, expected.importance)
        XCTAssertEqual(item.deadline, expected.deadline)
        XCTAssertEqual(item.isDone, expected.isDone)
        XCTAssertEqual(item.createdAt, expected.createdAt)
        XCTAssertEqual(item.modifiedAt, expected.modifiedAt)
    }

    func testParseNonDefault() {
        let jsonObject: [String: Any] = [
            "id": "123",
            "text": "Todo",
            "importance": "high",
            "isDone": true,
            "createdAt": "2022-07-28T06:00:00Z",
            "modifiedAt": "2022-07-30T18:00:00Z",
            "deadline": "2022-07-31T20:59:59Z",
        ]
        guard let item = TodoItem.parse(json: jsonObject) else {
            XCTFail("Invalid data passed: \(jsonObject)")
            return
        }

        let createdAt = Date(timeIntervalSince1970: 1658988000) // 2022.07.29 09:00:00 GMT+0300
        let modifiedAt = Date(timeIntervalSince1970: 1659204000) // 2022.07.30 21:00:00 GMT+0300
        let deadline = Date(timeIntervalSince1970: 1659301199) // 2022.07.31 23:59:59 GMT+0300
        let expected = TodoItem(
            id: "123",
            text: "Todo",
            importance: .high,
            deadline: deadline,
            isDone: true,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )

        XCTAssertEqual(item.id, expected.id)
        XCTAssertEqual(item.text, expected.text)
        XCTAssertEqual(item.importance, expected.importance)
        XCTAssertEqual(item.deadline, expected.deadline)
        XCTAssertEqual(item.isDone, expected.isDone)
        XCTAssertEqual(item.createdAt, expected.createdAt)
        XCTAssertEqual(item.modifiedAt, expected.modifiedAt)
    }

    func testGenerateDefault() {
        let createdAt = Date(timeIntervalSince1970: 1658988000) // 2022.07.29 09:00:00 GMT+0300
        let item = TodoItem(
            id: "123",
            text: "Todo",
            importance: .medium,
            deadline: nil,
            isDone: false,
            createdAt: createdAt,
            modifiedAt: nil
        )
        let object = item.json

        let expected: [String: Any] = [
            "id": "123",
            "text": "Todo",
            "isDone": false,
            "createdAt": "2022-07-28T06:00:00Z",
        ]

        guard let jsonObject = object as? [String: Any] else {
            XCTFail("Invalid type returned: \(object)")
            return
        }

        XCTAssertEqual(NSDictionary(dictionary: jsonObject), NSDictionary(dictionary: expected))
    }

    func testGenerateNonDefault() {
        let createdAt = Date(timeIntervalSince1970: 1658988000) // 2022.07.29 09:00:00 GMT+0300
        let modifiedAt = Date(timeIntervalSince1970: 1659204000) // 2022.07.30 21:00:00 GMT+0300
        let deadline = Date(timeIntervalSince1970: 1659301199) // 2022.07.31 23:59:59 GMT+0300
        let item = TodoItem(
            id: "123",
            text: "Todo",
            importance: .high,
            deadline: deadline,
            isDone: true,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
        let object = item.json

        let expected: [String: Any] = [
            "id": "123",
            "text": "Todo",
            "importance": "high",
            "isDone": true,
            "createdAt": "2022-07-28T06:00:00Z",
            "modifiedAt": "2022-07-30T18:00:00Z",
            "deadline": "2022-07-31T20:59:59Z",
        ]

        guard let jsonObject = object as? [String: Any] else {
            XCTFail("Invalid type returned: \(object)")
            return
        }

        XCTAssertEqual(NSDictionary(dictionary: jsonObject), NSDictionary(dictionary: expected))
    }
}
