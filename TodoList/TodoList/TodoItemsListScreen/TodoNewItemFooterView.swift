//
//  TodoNewItemFooter.swift
//  TodoList
//
//  Created by Olga Zorina on 8/7/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class TodoNewItemFooterView: UITableViewHeaderFooterView {
    var viewModel: TodoNewItemFooterViewModel {
        didSet {
            self.updateView()
        }
    }

    private enum Consts {
        static let separatorViewHeight: CGFloat = 1
        static let newItemTextFieldHeight: CGFloat = 55
        static let newItemTextFieldLeftInset: CGFloat = 52
    }
    
    private let newItemTextField: UITextField = {
        let textField = UITextField()
        textField.font = FontScheme.shared.body
        textField.placeholder = "Новое"
        textField.returnKeyType = UIReturnKeyType.done
        return textField
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorScheme.shared.separator
        return view
    }()

    override init(reuseIdentifier: String?) {
        self.viewModel = TodoNewItemFooterViewModel.makeDefault()
        
        super.init(reuseIdentifier: reuseIdentifier)

        self.newItemTextField.delegate = self

        self.contentView.backgroundColor = ColorScheme.shared.backSecondary
        self.contentView.addSubview(self.newItemTextField)
        self.contentView.addSubview(self.separatorView)

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.separatorView.leadingAnchor.constraint(equalTo: self.newItemTextField.leadingAnchor),
            self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.separatorView.topAnchor.constraint( equalTo: self.contentView.topAnchor),
            self.separatorView.bottomAnchor.constraint(equalTo: self.newItemTextField.topAnchor),
            self.separatorView.heightAnchor.constraint(equalToConstant: Consts.separatorViewHeight),
        ])

        self.newItemTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.newItemTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Consts.newItemTextFieldLeftInset),
            self.newItemTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.newItemTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.newItemTextField.heightAnchor.constraint(equalToConstant: Consts.newItemTextFieldHeight),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateView() {
        let viewModel = self.viewModel
        self.separatorView.backgroundColor = viewModel.isSeparatorHidden ? self.contentView.backgroundColor : ColorScheme.shared.separator
        self.newItemTextField.text = viewModel.text
    }
}

extension TodoNewItemFooterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            self.viewModel.text = text
            self.viewModel.didTapDone?()
        }
        textField.resignFirstResponder()
        return true
    }
}
