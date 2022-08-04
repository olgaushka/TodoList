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
                fileCache.removeBy(id: item.id)
                self.scrollView.viewModel = TodoItemScrollViewModel.makeDefault()
            }
            self.scrollView.viewModel = viewModel
        }

        view.backgroundColor = UIColor(red: 0.97, green: 0.966, blue: 0.951, alpha: 1)
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
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    @objc
    private func done() {
        print("Сохранить")

        let fileCache = FileCache()
        fileCache.load(from: "test.json")
        let viewModel = self.scrollView.viewModel
        if let item = fileCache.items.first {
            fileCache.removeBy(id: item.id)
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

