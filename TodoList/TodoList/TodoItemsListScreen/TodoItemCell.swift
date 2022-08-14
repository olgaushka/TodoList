//
//  TodoItemCell.swift
//  TodoList
//
//  Created by Olga Zorina on 8/5/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class TodoItemCell: UITableViewCell {
    var viewModel: TodoItemCellViewModel {
        didSet {
            self.updateView()
        }
    }

    private enum Consts {
        static let dateFormat: String = "d MMMM yyyy"
        static let doneButtonInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
        static let doneButtonSize: CGSize = .init(width: 24, height: 24)
        static let importanceImageViewInsets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 0)
        // swiftlint:disable:next identifier_name
        static let itemTextLabelToImportanceImageViewLeftInset: CGFloat = 5
        static let itemTextLabelToDoneButtonLeftInset: CGFloat = 12
        static let itemTextLabelInsets: UIEdgeInsets = .init(top: 16, left: 0, bottom: 12, right: 16)
        static let calendarImageViewInsets: UIEdgeInsets = .init(top: 2, left: 0, bottom: 12, right: 0)
        static let deadlineLabelInsets: UIEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 0)
    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Consts.dateFormat
        return dateFormatter
    }()

    private let doneButton: UIButton = {
        let doneButton = UIButton()
        return doneButton
    }()

    private let importanceImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()

    private let itemTextLabel: UILabel = {
        let label = UILabel()
        label.font = FontScheme.shared.body
        label.numberOfLines = 3
        return label
    }()

    private let calendarImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "Icon Calendar")
        return img
    }()

    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = FontScheme.shared.subhead
        label.textColor = ColorScheme.shared.labelTertiary
        return label
    }()

    private var deadlineCalendarImageBottomConstraint: NSLayoutConstraint
    private var itemTextLabelBottomConstraint: NSLayoutConstraint
    private var importanceImageViewWidthConstraint: NSLayoutConstraint
    private var importanceImageViewHeightConstraint: NSLayoutConstraint
    // swiftlint:disable:next identifier_name
    private var itemTextLabelToImportanceImageViewLeadingConstraint: NSLayoutConstraint
    // swiftlint:disable:next identifier_name
    private var itemTextLabelToDoneButtonLeadingConstraint: NSLayoutConstraint

    // swiftlint:disable:next function_body_length
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.viewModel = TodoItemCellViewModel.makeDefault()

        self.deadlineCalendarImageBottomConstraint = NSLayoutConstraint()
        self.itemTextLabelBottomConstraint = NSLayoutConstraint()
        self.importanceImageViewWidthConstraint = NSLayoutConstraint()
        self.importanceImageViewHeightConstraint = NSLayoutConstraint()
        self.itemTextLabelToImportanceImageViewLeadingConstraint = NSLayoutConstraint()
        self.itemTextLabelToDoneButtonLeadingConstraint = NSLayoutConstraint()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        self.contentView.backgroundColor = ColorScheme.shared.backSecondary

        self.contentView.addSubview(self.doneButton)
        self.doneButton.addTarget(self, action: #selector(doneButtonClicked(_:)), for: .touchUpInside)
        self.contentView.addSubview(self.importanceImageView)
        self.contentView.addSubview(self.itemTextLabel)
        self.contentView.addSubview(self.calendarImageView)
        self.contentView.addSubview(self.deadlineLabel)

        self.doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.doneButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.doneButton.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor,
                constant: Consts.doneButtonInsets.left
            ),
            self.doneButton.widthAnchor.constraint(equalToConstant: Consts.doneButtonSize.width),
            self.doneButton.heightAnchor.constraint(equalToConstant: Consts.doneButtonSize.height),
        ])

        self.importanceImageView.translatesAutoresizingMaskIntoConstraints = false
        self.importanceImageViewWidthConstraint = self.importanceImageView.widthAnchor.constraint(equalToConstant: 0)
        self.importanceImageViewHeightConstraint = self.importanceImageView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            self.importanceImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.importanceImageView.leadingAnchor.constraint(
                equalTo: self.doneButton.trailingAnchor,
                constant: Consts.importanceImageViewInsets.left
            ),
            self.importanceImageViewWidthConstraint,
            self.importanceImageViewHeightConstraint,
        ])

        self.itemTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.itemTextLabelToImportanceImageViewLeadingConstraint = self.itemTextLabel.leadingAnchor.constraint(
            equalTo: self.importanceImageView.trailingAnchor,
            constant: Consts.itemTextLabelToImportanceImageViewLeftInset
        )
        self.itemTextLabelToDoneButtonLeadingConstraint = self.itemTextLabel.leadingAnchor.constraint(
            equalTo: self.doneButton.trailingAnchor,
            constant: Consts.itemTextLabelToDoneButtonLeftInset
        )
        self.itemTextLabelBottomConstraint = self.itemTextLabel.bottomAnchor.constraint(
            equalTo: self.contentView.bottomAnchor,
            constant: -Consts.itemTextLabelInsets.bottom
        )
        NSLayoutConstraint.activate([
            self.itemTextLabel.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: Consts.itemTextLabelInsets.top
            ),
            self.itemTextLabelToImportanceImageViewLeadingConstraint,
            self.itemTextLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: self.contentView.trailingAnchor,
                constant: -Consts.itemTextLabelInsets.right
            ),
        ])

        self.calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.deadlineCalendarImageBottomConstraint = self.calendarImageView.bottomAnchor.constraint(
            equalTo: self.contentView.bottomAnchor,
            constant: -Consts.calendarImageViewInsets.bottom
        )
        NSLayoutConstraint.activate([
            self.calendarImageView.topAnchor.constraint(
                equalTo: self.itemTextLabel.bottomAnchor,
                constant: Consts.calendarImageViewInsets.top
            ),
            self.calendarImageView.leadingAnchor.constraint(
                equalTo: self.itemTextLabel.leadingAnchor,
                constant: 0
            ),
            self.calendarImageView.widthAnchor.constraint(
                equalToConstant: self.calendarImageView.image?.size.width ?? 0
            ),
            self.calendarImageView.heightAnchor.constraint(
                equalToConstant: self.calendarImageView.image?.size.height ?? 0
            ),
            self.deadlineCalendarImageBottomConstraint,
        ])

        self.deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.deadlineLabel.topAnchor.constraint(equalTo: self.calendarImageView.topAnchor),
            self.deadlineLabel.leadingAnchor.constraint(
                equalTo: self.calendarImageView.trailingAnchor,
                constant: Consts.deadlineLabelInsets.left
            ),
        ])
     }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable:next function_body_length
    private func updateView() {
        let viewModel = self.viewModel
        var deadlineIsMissed = false

        if let deadline = viewModel.deadline {
            self.calendarImageView.isHidden = false
            self.deadlineLabel.isHidden = false
            self.deadlineLabel.text = self.dateFormatter.string(from: deadline)
            self.itemTextLabelBottomConstraint.isActive = false
            self.deadlineCalendarImageBottomConstraint.isActive = true
            if deadline < Date() {
                deadlineIsMissed = true
            }
        } else {
            self.calendarImageView.isHidden = true
            self.deadlineLabel.isHidden = true
            self.deadlineCalendarImageBottomConstraint.isActive = false
            self.itemTextLabelBottomConstraint.isActive = true
        }

        switch viewModel.importance {
        case .low:
            self.importanceImageView.isHidden = false
            self.importanceImageView.image = UIImage(named: "Icon Arrow")

            self.importanceImageViewWidthConstraint.constant = importanceImageView.image?.size.width ?? 0
            self.importanceImageViewHeightConstraint.constant = importanceImageView.image?.size.height ?? 0
            self.itemTextLabelToDoneButtonLeadingConstraint.isActive = false
            self.itemTextLabelToImportanceImageViewLeadingConstraint.isActive = true
        case .medium:
            self.importanceImageView.isHidden = true
            self.itemTextLabelToImportanceImageViewLeadingConstraint.isActive = false
            self.itemTextLabelToDoneButtonLeadingConstraint.isActive = true

        case .high:
            self.importanceImageView.isHidden = false
            self.importanceImageView.image = UIImage(named: "Icon Exclamation")
            self.importanceImageViewWidthConstraint.constant = importanceImageView.image?.size.width ?? 0
            self.importanceImageViewHeightConstraint.constant = importanceImageView.image?.size.height ?? 0
            self.itemTextLabelToImportanceImageViewLeadingConstraint.isActive = true
            self.itemTextLabelToDoneButtonLeadingConstraint.isActive = false
        }

        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: viewModel.text)
        self.itemTextLabel.attributedText = attributeString
        self.itemTextLabel.textColor = ColorScheme.shared.labelPrimary

        if viewModel.isDone {
            self.doneButton.setBackgroundImage(UIImage(named: "Cell Done"), for: .normal)
            attributeString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: 1,
                range: NSRange(location: 0, length: attributeString.length)
            )
            self.itemTextLabel.attributedText = attributeString
            self.itemTextLabel.textColor = ColorScheme.shared.labelTertiary
        } else {
            if deadlineIsMissed {
                self.doneButton.setBackgroundImage(UIImage(named: "Cell Deadline"), for: .normal)
            } else {
                self.doneButton.setBackgroundImage(UIImage(named: "Cell Normal"), for: .normal)
            }
        }
    }

    @objc
    private func doneButtonClicked(_ button: UIButton) {
        self.viewModel.didTapDone?()
        self.updateView()
    }
}
