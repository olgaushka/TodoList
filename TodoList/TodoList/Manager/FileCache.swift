//
//  FileCache.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation
import TodoListModels

final class FileCache {
    var items: [TodoItem] = []
    var revision: Int32 = 0

    func add(item: TodoItem) {
        if self.items.contains(where: { $0.id == item.id }) { return }
        self.items.append(item)
    }

    func removeBy(id: String) {
        self.items.removeAll { $0.id == id }
    }

    func modify(item: TodoItem) {
        for (index, value) in self.items.enumerated() where value.id == item.id {
            self.items[index] = item
        }
    }

    func save(to fileName: String) {
        guard let fileURL = fileURL(for: fileName) else { return }

        let jsonItems = self.items.map({ item in
            item.json
        })
        let json:[ String: Any ] = [ "revision": self.revision, "items": jsonItems ]
        if JSONSerialization.isValidJSONObject(jsonItems) {
            do {
                let rawData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                try rawData.write(to: fileURL, options: .atomic)
            } catch {
                // Handle Error
            }
        }
    }

    func load(from fileName: String) {
        guard let fileURL = fileURL(for: fileName) else { return }

        do {
            let data = try? Data(contentsOf: fileURL)
            if let jsonData = data {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                if let dict = jsonObject as? [String: Any],
                   let arr = dict["items"] as? [[String: Any]] {
                    let items = arr.compactMap({ item in
                        TodoItem.parse(json: item)
                    })
                    self.items = items
                    self.revision = dict["revision"] as? Int32 ?? 0
                }
            }
        } catch {
            // Handle Error
        }
    }

    private func fileURL(for fileName: String) -> URL? {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let cachesDirectoryPath = path else { return nil }

        let dirURL = cachesDirectoryPath.appendingPathComponent("TodoList")

        var fileURL: URL?
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDir), isDir.boolValue {
            fileURL = dirURL.appendingPathComponent(fileName)
        } else {
            do {
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
            fileURL = dirURL.appendingPathComponent(fileName)
        }
        return fileURL
    }
}
