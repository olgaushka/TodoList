//
//  TodoItemsListViewController.swift
//  TodoList
//
//  Created by Olga Zorina on 8/4/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class TodoItemsListViewController: UIViewController {
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.font = FontScheme.shared.subhead
        label.textColor = ColorScheme.shared.labelTertiary
        return label
    }()
    private let showAllButton: UIButton = {
         let button = UIButton()
        button.setTitleColor(ColorScheme.shared.blue, for: .normal)
        button.titleLabel?.font = FontScheme.shared.subheadline
        button.contentEdgeInsets = UIEdgeInsets(top: .leastNormalMagnitude, left: .leastNormalMagnitude, bottom: .leastNormalMagnitude, right: .leastNormalMagnitude)
        return button
    }()

    private let dependencies: Dependencies

    private let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Button Add"), for: .normal)
        return button
    }()

    private var itemViewModels: [TodoItemCellViewModel] = []
    private var showAll: Bool = true


    private let itemsTableView: DynamicTableView = DynamicTableView(frame: .zero, style: .plain)
//    private var tableSize: CGFloat = 0

    private var addButtonBottomConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint()
    }()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        view.backgroundColor = ColorScheme.shared.backPrimary

        self.view.addSubview(self.completedLabel)
        self.completedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.completedLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.completedLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
        ])

        self.view.addSubview(self.showAllButton)
        self.showAllButton.addTarget(self, action: #selector(showAllButtonClicked(_:)), for: .touchUpInside)
        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.showAllButton.topAnchor.constraint(equalTo: self.completedLabel.topAnchor),
            self.showAllButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
        ])

        self.updateViewModels()

        self.view.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(addButtonClicked(_:)), for: .touchUpInside)
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addButtonBottomConstraint = self.addButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        NSLayoutConstraint.activate([
            self.addButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.addButtonBottomConstraint
        ])

        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        itemsTableView.register(TodoItemCell.self, forCellReuseIdentifier: "itemCell")
        itemsTableView.register(TodoNewItemFooterView.self, forHeaderFooterViewReuseIdentifier: "footerCell")
        self.view.addSubview(self.itemsTableView)
        self.itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemsTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            itemsTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            itemsTableView.topAnchor.constraint(equalTo: self.completedLabel.bottomAnchor, constant: 12),
            itemsTableView.bottomAnchor.constraint(lessThanOrEqualTo: self.addButton.topAnchor, constant:-14),

        ])
        itemsTableView.layer.cornerRadius = 16
        itemsTableView.separatorInset.left = 52
        itemsTableView.separatorColor = ColorScheme.shared.separator
        itemsTableView.estimatedSectionFooterHeight = 56

        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.addButton.layer.shadowPath = UIBezierPath(ovalIn: self.addButton.bounds).cgPath
        self.addButton.layer.shadowRadius = 10
        self.addButton.layer.shadowOpacity = 0.2
        self.addButton.layer.shadowOffset = CGSize(width: 0, height: self.addButton.bounds.height/4)
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Мои дела"
        self.navigationController?.navigationBar.isTranslucent = true
    }

    private func updateViewModels() {
        let dependencies = self.dependencies
        dependencies.fileCache.load(from: dependencies.fileName)
        let allItems = dependencies.fileCache.items
        let notCompletedItems = allItems.filter({ !$0.isDone })
        self.completedLabel.text = "Выполнено — \(allItems.count - notCompletedItems.count)"
        let items: [TodoItem]
        if showAll {
            items = allItems
            self.showAllButton.setTitle("Скрыть", for: .normal)
        } else {
            items = notCompletedItems
            self.showAllButton.setTitle("Показать", for: .normal)
        }
        self.itemViewModels = items.map({ item in
            let viewModel = TodoItemCellViewModel(
                id: item.id,
                text: item.text,
                importance: item.importance,
                deadline: item.deadline,
                isDone: item.isDone
            )
            return viewModel
        })
    }

    private func didTapInfo(viewModel: TodoItemCellViewModel?) {
        let todoItemViewController = TodoItemViewController(dependencies: self.dependencies)
        if let item = self.dependencies.fileCache.items.first(where: { $0.id == viewModel?.id }) {
            todoItemViewController.item = item
        }
        todoItemViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: todoItemViewController)
        self.present(navigationController, animated: true, completion: nil)
    }

    private func didTapDelete(viewModel: TodoItemCellViewModel) {
        let dependencies = self.dependencies
        dependencies.fileCache.removeBy(id: viewModel.id)
        dependencies.fileCache.save(to: dependencies.fileName)
        self.updateData()
    }

    private func didTapDone(viewModel: TodoItemCellViewModel) {
        let dependencies = self.dependencies
        guard let item = dependencies.fileCache.items.first(where: { $0.id == viewModel.id }) else { return }
        let changedItem = item.toggleCompleted()
        dependencies.fileCache.modify(item: changedItem)
        dependencies.fileCache.save(to: dependencies.fileName)
        self.updateData()
    }

    func updateData() {
        self.updateViewModels()
        self.itemsTableView.reloadData()
    }

    @objc
    private func showAllButtonClicked(_ button: UIButton) {
        self.showAll = !self.showAll
        self.updateData()
    }

    @objc
    private func addButtonClicked(_ button: UIButton) {
        self.didTapInfo(viewModel: nil)
    }

    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }

        addButtonBottomConstraint.constant = -20 - keyboardHeight
    }

    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        addButtonBottomConstraint.constant = -20
    }
}

extension TodoItemsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.itemViewModels.count
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        guard let cell = tableViewCell as? TodoItemCell else { return tableViewCell }
        let viewModel = self.itemViewModels[indexPath.row]
        viewModel.didTapDone = { [weak self] in
            guard let self = self else { return }
            self.didTapDone(viewModel: viewModel)
        }
        cell.viewModel = viewModel
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footerCell")
        guard let footerView = footer as? TodoNewItemFooterView else { return nil }
        let footerViewModel: TodoNewItemFooterViewModel
        if self.itemViewModels.count == 0 {
            footerViewModel = TodoNewItemFooterViewModel(text: "", isSeparatorHidden: true)
        } else {
            footerViewModel = TodoNewItemFooterViewModel(text: "", isSeparatorHidden: false)
        }
        footerViewModel.didTapDone = { [weak self] in
            guard let self = self else { return }

            let newItem = TodoItem(text: footerViewModel.text)
            let dependencies = self.dependencies
            dependencies.fileCache.add(item: newItem)
            dependencies.fileCache.save(to: dependencies.fileName)
            self.updateData()
            UIView.setAnimationsEnabled(false)
            self.itemsTableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.none)
            UIView.setAnimationsEnabled(true)
        }
        footerView.viewModel = footerViewModel
        return footerView
    }

}

extension TodoItemsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.itemViewModels[indexPath.row]
        self.didTapInfo(viewModel: viewModel)

        self.itemsTableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let viewModel = self.itemViewModels[indexPath.row]
            self.didTapDone(viewModel: viewModel)
            completionHandler(true)
        }

        action.backgroundColor = ColorScheme.shared.green
        action.image = UIImage(named: "Action Check")
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewModel = self.itemViewModels[indexPath.row]
        let info = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self.didTapInfo(viewModel: viewModel)
            completionHandler(true)
        }
        info.backgroundColor = ColorScheme.shared.grayLight
        info.image = UIImage(named: "Action Info")

        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: nil) { [weak self] (action, view, completionHandler) in
            self?.didTapDelete(viewModel: viewModel)
            completionHandler(true)
        }
        trash.backgroundColor = ColorScheme.shared.red
        trash.image = UIImage(named: "Action Trash")

        let configuration = UISwipeActionsConfiguration(actions: [trash, info])

        return configuration
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension TodoItemsListViewController: TodoItemViewControllerDelegate {
    func todoItemViewControllerDidFinish(_ viewController: TodoItemViewController) {
        self.updateData()
    }
}

class DynamicTableView: UITableView {
    /// Will assign automatic dimension to the rowHeight variable
    /// Will asign the value of this variable to estimated row height.
    var dynamicRowHeight: CGFloat = UITableView.automaticDimension {
        didSet {
            rowHeight = UITableView.automaticDimension
            estimatedRowHeight = dynamicRowHeight
        }
    }

    public override var intrinsicContentSize: CGSize {
        return contentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
}


