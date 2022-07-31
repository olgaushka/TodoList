//
//  TodoItemViewController.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

class TodoItemViewController: UIViewController {
    private let scrollView: TodoItemScrollView = .init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        let fileCache = FileCache()
        fileCache.load(from: "test.json")
        if let item = fileCache.items.first {
            let viewModel = TodoItemScrollViewModel(text: item.text, importance: item.importance, deadline: item.deadline)
            viewModel.didTapDelete = { [weak self] in
                guard let self = self else { return }
                fileCache.remove(item: item)
                self.scrollView.viewModel = TodoItemScrollViewModel.makeDefault()
            }
            self.scrollView.viewModel = viewModel
        }

        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        self.navigationItem.title = "Дело"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    @objc
    private func done() {
        print("Сохранить")

        let fileCache = FileCache()
        fileCache.load(from: "test.json")
        let viewModel = self.scrollView.viewModel
        if let item = fileCache.items.first {
            fileCache.remove(item: item)
            let changedItem = TodoItem(id: item.id, text: viewModel.text, importance: viewModel.importance, deadline: viewModel.deadline, isDone: item.isDone, createdAt: item.createdAt, modifiedAt: Date())
            fileCache.add(item: changedItem)
        } else {
            let newItem = TodoItem(text: viewModel.text, importance: viewModel.importance, deadline: viewModel.deadline, isDone: false, createdAt: Date())
            fileCache.add(item: newItem)
        }
        fileCache.save(to: "test.json")
    }

    @objc
    private func cancel() {
        print("Отменить")
    }
}

