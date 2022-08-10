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
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    weak var delegate: TodoItemViewControllerDelegate?
    var item: TodoItem = TodoItem(text: "")

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)

        let viewModel = TodoItemScrollViewModel(text: self.item.text, importance: self.item.importance, deadline: self.item.deadline)
        viewModel.didTapDelete = { [weak self] in
            guard let self = self else { return }
            let dependencies = self.dependencies
            dependencies.fileCache.removeBy(id: self.item.id)
            dependencies.fileCache.save(to: dependencies.fileName)
            self.delegate?.todoItemViewControllerDidFinish(self)
            self.dismiss(animated: true)
        }
        self.scrollView.viewModel = viewModel

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.isEnabled = false
        self.view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture



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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }

    private func setupNavigationBar() {
        self.navigationItem.title = "Дело"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc
    private func keyboardDidShow() {
        self.tapGesture.isEnabled = true
    }

    @objc
    private func keyboardDidHide() {
        self.tapGesture.isEnabled = false
    }

    @objc
    private func done() {
        print("Сохранить")

        let viewModel = self.scrollView.viewModel
        let dependencies = self.dependencies
        if let item = dependencies.fileCache.items.first(where: { $0.id == self.item.id }) {
            let changedItem = TodoItem(id: item.id, text: viewModel.text, importance: viewModel.importance, deadline: viewModel.deadline, isDone: item.isDone, createdAt: item.createdAt, modifiedAt: Date())
            dependencies.fileCache.modify(item: changedItem)
        } else {
            let newItem = TodoItem(text: viewModel.text, importance: viewModel.importance, deadline: viewModel.deadline, isDone: false, createdAt: Date())
            dependencies.fileCache.add(item: newItem)
        }
        dependencies.fileCache.save(to: dependencies.fileName)
        self.delegate?.todoItemViewControllerDidFinish(self)
        self.dismiss(animated: true)
    }

    @objc
    private func cancel() {
        print("Отменить")
        self.dismiss(animated: true)
    }
}

protocol TodoItemViewControllerDelegate: AnyObject {
    func todoItemViewControllerDidFinish(_ viewController: TodoItemViewController)
}

