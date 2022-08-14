//
//  TodoItem.swift
//  TodoList
//
//  Created by Olga Zorina on 8/13/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import Foundation

public final class TodoListResources {
    public static let bundle: Bundle? = {
        let classBundle = Bundle(for: TodoListResources.self)

        let resourceName = "TodoListResourcesBundle"
        guard let resourceBundleURL = classBundle.url(forResource: resourceName, withExtension: "bundle") else {
            print("\(resourceName).bundle not found!")
            return nil
        }

        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            print("Cannot access \(resourceName).bundle!")
            return nil
        }

        return resourceBundle
    }()
}
