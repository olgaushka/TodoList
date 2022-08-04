//
//  FileCache.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

final class FileCache {

    public private(set) var items: [TodoItem]
    init() {
        items = []
    }

    func add(item: TodoItem) {
        for value in self.items {
            if value.id == item.id {
                return
            }
        }
        self.items.append(item)
    }

    func remove(item: TodoItem) {
        for (index, value) in self.items.enumerated() {
            if value.id == item.id {
                self.items.remove(at: index)
            }
        }
    }

    func save(to fileName: String) {
        guard let fileURL = fileURL(for: fileName) else { return }
        
        let jsonItems = self.items.map({ item in
            item.json
        })
        if JSONSerialization.isValidJSONObject(jsonItems) {
            do {
                let rawData = try JSONSerialization.data(withJSONObject: jsonItems, options: .prettyPrinted)
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
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options:[])
                if let arr = jsonObject as? [[String: Any]] {
                    let items = arr.compactMap({ item in
                        TodoItem.parse(json: item)
                    })
                    self.items = items
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

        var fileURL: URL? = nil
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

