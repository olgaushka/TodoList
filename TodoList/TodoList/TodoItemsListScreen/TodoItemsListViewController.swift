//
//  TodoItemsListViewController.swift
//  TodoList
//
//  Created by Olga Zorina on 8/4/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

// swiftlint:disable file_length

import UIKit
import CocoaLumberjack
import TodoListModels
import TodoListResources

final class TodoItemsListViewController: UIViewController {
    private let dependencies: Dependencies
    private var itemViewModels: [TodoItemCellViewModel] = []
    private var showAll: Bool = true

    private enum Consts {
        static let cellReuseIdentifier: String = "itemCell"
        static let footerReuseIdentifier: String = "footerCell"
        static let cornerRadius: CGFloat = 16
        static let leftSeparatorInset: CGFloat = 52
        static let completedLabelInsets: UIEdgeInsets = .init(top: 8, left: 32, bottom: 0, right: 0)
        static let showAllButtonInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 32)
        static let addButtonInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 20, right: 0)
        static let itemsTableViewInsets: UIEdgeInsets = .init(top: 12, left: 16, bottom: 14, right: 16)
        static let addButtonShadowRadius: CGFloat = 10
        static let addButtonShadowOpacity: Float = 0.2
        static let addButtonShadowOffsetSizeRatio: CGSize = CGSize(width: 0.0, height: 0.25)
        static let estimatedItemsTableViewFooterHeight: CGFloat = 56
    }

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
        button.contentEdgeInsets = UIEdgeInsets(
            top: .leastNormalMagnitude,
            left: .leastNormalMagnitude,
            bottom: .leastNormalMagnitude,
            right: .leastNormalMagnitude
        )
        return button
    }()
    private let addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Button Add", in: TodoListResources.bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()
    private let itemsTableView: DynamicTableView = DynamicTableView(frame: .zero, style: .plain)
    private var addButtonBottomConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint()
    }()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = ColorScheme.shared.backPrimary

        self.view.addSubview(self.completedLabel)
        self.completedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.completedLabel.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: Consts.completedLabelInsets.left
            ),
            self.completedLabel.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                constant: Consts.completedLabelInsets.top
            ),
        ])

        self.view.addSubview(self.showAllButton)
        self.showAllButton.addTarget(self, action: #selector(showAllButtonClicked(_:)), for: .touchUpInside)
        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.showAllButton.topAnchor.constraint(equalTo: self.completedLabel.topAnchor),
            self.showAllButton.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Consts.showAllButtonInsets.right
            ),
        ])

        self.view.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(addButtonClicked(_:)), for: .touchUpInside)
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addButtonBottomConstraint = self.addButton.bottomAnchor.constraint(
            equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Consts.addButtonInsets.bottom
        )
        NSLayoutConstraint.activate([
            self.addButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.addButtonBottomConstraint
        ])

        self.itemsTableView.dataSource = self
        self.itemsTableView.delegate = self
        self.itemsTableView.register(
            TodoItemCell.self,
            forCellReuseIdentifier: Consts.cellReuseIdentifier
        )
        self.itemsTableView.register(
            TodoNewItemFooterView.self,
            forHeaderFooterViewReuseIdentifier: Consts.footerReuseIdentifier
        )
        self.itemsTableView.estimatedSectionFooterHeight = Consts.estimatedItemsTableViewFooterHeight
        self.itemsTableView.layer.cornerRadius = Consts.cornerRadius
        self.itemsTableView.separatorInset.left = Consts.leftSeparatorInset
        self.itemsTableView.separatorColor = ColorScheme.shared.separator
        self.view.addSubview(self.itemsTableView)
        self.itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.itemsTableView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: Consts.itemsTableViewInsets.left
            ),
            self.itemsTableView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Consts.itemsTableViewInsets.right
            ),
            self.itemsTableView.topAnchor.constraint(
                equalTo: self.completedLabel.bottomAnchor,
                constant: Consts.itemsTableViewInsets.top
            ),
            self.itemsTableView.bottomAnchor.constraint(
                lessThanOrEqualTo: self.addButton.topAnchor,
                constant: -Consts.itemsTableViewInsets.bottom
            ),
        ])

        self.setupNavigationBar()
        self.loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.addButton.layer.shadowPath = UIBezierPath(ovalIn: self.addButton.bounds).cgPath
        self.addButton.layer.shadowRadius = Consts.addButtonShadowRadius
        self.addButton.layer.shadowOpacity = Consts.addButtonShadowOpacity
        self.addButton.layer.shadowOffset = CGSize(
            width: self.addButton.bounds.height * Consts.addButtonShadowOffsetSizeRatio.width,
            height: self.addButton.bounds.height * Consts.addButtonShadowOffsetSizeRatio.height
        )
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Мои дела"
        self.navigationController?.navigationBar.isTranslucent = true
    }

    private func loadData() {
        self.dependencies.fileCacheService.load(from: self.dependencies.fileName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
            case .failure(let error):
                DDLogError(error.localizedDescription)
                self.showErrorAlert()
            }
        }
    }

    private func saveData() {
        self.dependencies.fileCacheService.save(to: self.dependencies.fileName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DDLogInfo("Save success")
            case .failure(let error):
                DDLogError(error.localizedDescription)
                self.showErrorAlert()
                self.loadData()
            }
        }
    }

    private func updateViewModels() {
        let allItems = self.dependencies.fileCacheService.items
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
        self.itemsTableView.reloadData()
    }

    private func didTapInfo(viewModel: TodoItemCellViewModel?) {
        let todoItemViewController = TodoItemViewController(dependencies: self.dependencies)
        if let item = self.dependencies.fileCacheService.items.first(where: { $0.id == viewModel?.id }) {
            todoItemViewController.item = item
        }
        todoItemViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: todoItemViewController)
        self.present(navigationController, animated: true, completion: nil)
    }

    private func didTapDelete(viewModel: TodoItemCellViewModel) {
        self.dependencies.fileCacheService.delete(id: viewModel.id)
        self.saveData()
        self.updateViewModels()
    }

    private func didTapDone(viewModel: TodoItemCellViewModel) {
        let dependencies = self.dependencies
        guard let item = dependencies.fileCacheService.items.first(where: { $0.id == viewModel.id }) else { return }
        let changedItem = item.toggleCompleted()
        self.dependencies.fileCacheService.modify(changedItem)
        self.saveData()
        self.updateViewModels()
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Во время выполнения запроса произошла ошибка",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    @objc
    private func showAllButtonClicked(_ button: UIButton) {
        self.showAll = !self.showAll
        self.updateViewModels()
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
        self.addButtonBottomConstraint.constant = -Consts.addButtonInsets.bottom - keyboardHeight
    }

    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        self.addButtonBottomConstraint.constant = -Consts.addButtonInsets.bottom
    }
}

extension TodoItemsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.itemViewModels.count
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: Consts.cellReuseIdentifier, for: indexPath)
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
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: Consts.footerReuseIdentifier)
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
            self.dependencies.fileCacheService.add(newItem)
            self.saveData()
            self.updateViewModels()
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

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let viewModel = self.itemViewModels[indexPath.row]
            self.didTapDone(viewModel: viewModel)
            completionHandler(true)
        }

        action.backgroundColor = ColorScheme.shared.green
        action.image = UIImage(named: "Action Check", in: TodoListResources.bundle, compatibleWith: nil)
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let viewModel = self.itemViewModels[indexPath.row]
        let info = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.didTapInfo(viewModel: viewModel)
            completionHandler(true)
        }
        info.backgroundColor = ColorScheme.shared.grayLight
        info.image = UIImage(named: "Action Info", in: TodoListResources.bundle, compatibleWith: nil)

        // Trash action
        let trash = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.didTapDelete(viewModel: viewModel)
            completionHandler(true)
        }
        trash.backgroundColor = ColorScheme.shared.red
        trash.image = UIImage(named: "Action Trash", in: TodoListResources.bundle, compatibleWith: nil)

        let configuration = UISwipeActionsConfiguration(actions: [trash, info])

        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension TodoItemsListViewController: TodoItemViewControllerDelegate {
    func todoItemViewControllerDidFinish(_ viewController: TodoItemViewController) {
        self.dismiss(animated: true)
        self.updateViewModels()
    }
}

class DynamicTableView: UITableView {
    /// Will assign automatic dimension to the rowHeight variable
    /// Will asign the value of this variable to estimated row height.
    var dynamicRowHeight: CGFloat = UITableView.automaticDimension {
        didSet {
            self.rowHeight = UITableView.automaticDimension
            self.estimatedRowHeight = self.dynamicRowHeight
        }
    }

    public override var intrinsicContentSize: CGSize {
        return self.contentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
}
