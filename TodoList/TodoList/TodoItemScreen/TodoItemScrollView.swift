//
//  TodoItemScrollView.swift
//  TodoList
//
//  Created by Olga Zorina on 7/31/22.
//  Copyright © 2022 Olga Zorina. All rights reserved.
//

import UIKit

final class TodoItemScrollView: UIScrollView {
    var viewModel: TodoItemScrollViewModel {
        didSet {
            self.updateView()
        }
    }

    private enum Consts {
        static let dateFormat: String = "d MMMM yyyy"
        static let oneDay: TimeInterval = 24 * 60 * 60
        static let cornerRadius: CGFloat = 16
        static let itemTextViewHeight: CGFloat = 120
        static let itemTextViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16)
        static let itemTextViewInnerInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let containerViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16)
        static let importanceLabelInsets: UIEdgeInsets = .init(top: 16, left: 17, bottom: 0, right: 0)
        static let importanceSegmentedControlInsets: UIEdgeInsets = .init(top: 10, left: 0, bottom: 0, right: 12)
        static let importanceSegmentedControlSize: CGSize = .init(width: 150, height: 36)
        static let dividerViewInsets: UIEdgeInsets = .init(top: 56, left: 16, bottom: 0, right: 16)
        static let dividerViewHeight: CGFloat = 1
        static let deadlineLabelInsets: UIEdgeInsets = .init(top: 17, left: 16, bottom: 26, right: 0)
        static let deadlineSwitchInsets: UIEdgeInsets = .init(top: 12, left: 0, bottom: 0, right: 12)
        static let deadlineButtonInsets: UIEdgeInsets = .init(top: 4, left: 16, bottom: 0, right: 0)
        static let datePickerInsets: UIEdgeInsets = .init(top: 9, left: 16, bottom: 0, right: 16)
        static let deleteButtonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16)
        static let deleteButtonHeight: CGFloat = 56

    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Consts.dateFormat
        return dateFormatter
    }()

    private let itemTextView: UITextView
    private let containerView: UIView
    private let importanceLabel: UILabel
    private let dividerView: UIView
    private let deadlineLabel: UILabel
    private let importanceSegmentedControl: UISegmentedControl
    private let deadlineSwitch: UISwitch
    private let deadlineButton: UIButton
    private let datePicker: UIDatePicker
    private let deleteButton: UIButton

    override init(frame: CGRect) {
        self.viewModel = TodoItemScrollViewModel.makeDefault()
        
        self.itemTextView = Self.makeItemTextView()
        self.containerView = Self.makeContainerView()
        self.importanceLabel = Self.makeImportanceLabel()
        self.importanceSegmentedControl = Self.makeSegmentedControl()
        self.dividerView = Self.makeDividerView()
        self.deadlineLabel = Self.makeDeadlineLabel()
        self.deadlineSwitch = Self.makeDeadlineSwitch()
        self.deadlineButton = Self.makeDeadlineButton()
        self.datePicker = Self.makeDatePicker()
        self.deleteButton = Self.makeDeleteButton()

        super.init(frame: frame)

        self.setupSubviews()
        self.updateView()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let isLandscape: Bool
        if #available(iOS 13.0, *) {
            isLandscape = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
        } else {
            isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        }

        if isLandscape {
            let itemTextViewWidth = self.bounds.width - Consts.itemTextViewInsets.left - Consts.itemTextViewInsets.right
            self.itemTextView.frame = .init(x: Consts.itemTextViewInsets.left, y: Consts.itemTextViewInsets.top, width: itemTextViewWidth, height: self.bounds.height)
            self.containerView.isHidden = true
            self.deleteButton.isHidden = true
        } else {

            self.containerView.isHidden = false
            self.deleteButton.isHidden = false

            let itemTextViewWidth = self.bounds.width - Consts.itemTextViewInsets.left - Consts.itemTextViewInsets.right
            let itemTextViewHeight = Consts.itemTextViewHeight

            self.itemTextView.frame = .init(x: Consts.itemTextViewInsets.left, y: Consts.itemTextViewInsets.top, width: itemTextViewWidth, height: itemTextViewHeight)

            self.containerView.frame.origin = .init(x: Consts.containerViewInsets.left, y: self.itemTextView.frame.maxY + Consts.containerViewInsets.top)


            self.importanceLabel.sizeToFit()
            self.importanceLabel.frame.origin = .init(x: Consts.importanceLabelInsets.left, y: Consts.importanceLabelInsets.top)

            self.importanceSegmentedControl.frame.size = .init(width: Consts.importanceSegmentedControlSize.width, height: Consts.importanceSegmentedControlSize.height)
            self.importanceSegmentedControl.frame.origin = .init(x: self.containerView.bounds.width - Consts.importanceSegmentedControlInsets.right - self.importanceSegmentedControl.bounds.width, y: Consts.importanceSegmentedControlInsets.top)

            self.dividerView.frame = .init(x: Consts.dividerViewInsets.left, y: Consts.dividerViewInsets.top, width: containerView.bounds.width - Consts.dividerViewInsets.left - Consts.dividerViewInsets.right, height: Consts.dividerViewHeight)

            self.deadlineLabel.sizeToFit()
            self.deadlineLabel.frame.origin = .init(x: Consts.deadlineLabelInsets.left,
                                                    y: self.dividerView.frame.maxY + Consts.deadlineLabelInsets.top)
            self.deadlineSwitch.sizeToFit()
            self.deadlineSwitch.frame.origin = .init(x: self.containerView.bounds.width - Consts.deadlineSwitchInsets.right - self.deadlineSwitch.frame.width,
                                                     y: self.dividerView.frame.maxY + Consts.deadlineSwitchInsets.top)
            self.deadlineButton.sizeToFit()
            self.deadlineButton.frame.origin = .init(x: Consts.deadlineButtonInsets.left,
                                                     y: self.deadlineLabel.frame.maxY + Consts.deadlineButtonInsets.top)


            let datePickerWidth = self.bounds.width - Consts.datePickerInsets.left - Consts.datePickerInsets.right
            let datePickerHeight = self.datePicker.sizeThatFits(.init(width: datePickerWidth, height: .greatestFiniteMagnitude)).height
            self.datePicker.frame = .init(
                origin: .init(x: 0, y: deadlineButton.frame.maxY + Consts.datePickerInsets.top),
                size: .init(width: datePickerWidth, height: datePickerHeight)
            )

            let containerViewLastElementMaxY: CGFloat
            if self.datePicker.isHidden {
                containerViewLastElementMaxY = self.deadlineLabel.frame.maxY + Consts.deadlineLabelInsets.bottom
            } else {
                containerViewLastElementMaxY = self.datePicker.frame.maxY
            }

            self.containerView.frame.size = .init(width: self.bounds.width - Consts.containerViewInsets.left - Consts.containerViewInsets.right, height: containerViewLastElementMaxY)

            self.deleteButton.frame.size = .init(width: self.bounds.width - Consts.deleteButtonInsets.left - Consts.deleteButtonInsets.right, height: Consts.deleteButtonHeight)
            self.deleteButton.frame.origin = .init(x: Consts.deleteButtonInsets.left, y: self.containerView.frame.maxY + Consts.deleteButtonInsets.top)

            self.contentSize = .init(width: self.bounds.width, height: self.deleteButton.frame.maxY)
        }
    }

    private static func makeItemTextView() -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = FontScheme.shared.body
        textView.textContainerInset = .init(top: Consts.itemTextViewInnerInsets.top, left: Consts.itemTextViewInnerInsets.left, bottom: Consts.itemTextViewInnerInsets.bottom, right: Consts.itemTextViewInnerInsets.right)
        textView.layer.cornerRadius = Consts.cornerRadius
//        textView.text = "Что надо сделать?"
//        textView.textColor = UIColor.lightGray
        return textView
    }

    private static func makeContainerView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = ColorScheme.shared.backSecondary
        view.layer.cornerRadius = 16
        return view
    }

    private static func makeImportanceLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Важность"
        label.font = FontScheme.shared.body
        return label
    }

    private static func makeSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["\u{2193}", "нет", "\u{203C}"])
        control.selectedSegmentIndex = 1
        return control
    }

    private static func makeDividerView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = ColorScheme.shared.separator
        return view
    }

    private static func makeDeadlineLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Сделать до"
        label.font = FontScheme.shared.body
        return label
    }

    private static func makeDeadlineSwitch() -> UISwitch {
        let control = UISwitch(frame: .zero)
        return control
    }

    private static func makeDeadlineButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.setTitleColor(ColorScheme.shared.blue, for: .normal)
        button.titleLabel?.font = FontScheme.shared.footnote
        button.contentEdgeInsets = UIEdgeInsets(top: .leastNormalMagnitude, left: .leastNormalMagnitude, bottom: .leastNormalMagnitude, right: .leastNormalMagnitude)
        button.contentHorizontalAlignment = .left
        button.isHidden = true
        return button
    }

    private static func makeDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.isHidden = true
        return datePicker
    }

    private static func makeDeleteButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(ColorScheme.shared.red, for: .normal)
        button.setTitleColor(ColorScheme.shared.labelTertiary, for: .disabled)
        button.titleLabel?.font = FontScheme.shared.body
        button.backgroundColor = ColorScheme.shared.backSecondary
        button.layer.cornerRadius = Consts.cornerRadius

        return button
    }

    private func setupSubviews() {
        addSubview(self.itemTextView)
        self.itemTextView.delegate = self

        addSubview(self.containerView)
        self.containerView.addSubview(self.importanceLabel)
        self.containerView.addSubview(self.importanceSegmentedControl)
        self.importanceSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        self.containerView.addSubview(self.dividerView)
        self.containerView.addSubview(self.deadlineLabel)
        self.containerView.addSubview(self.deadlineSwitch)
        self.deadlineSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        self.containerView.addSubview(self.deadlineButton)
        self.deadlineButton.addTarget(self, action: #selector(deadlineButtonClicked(_:)), for: .touchUpInside)

        self.containerView.addSubview(self.datePicker)
        self.datePicker.addTarget(self, action: #selector(onDateValueChanged(_:)), for: .valueChanged)

        addSubview(self.deleteButton)
        self.deleteButton.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
    }

    private func updateView() {
        let viewModel = self.viewModel

        self.itemTextView.text = viewModel.text

        let selectedSegmentIndex: Int
        switch viewModel.importance {
        case .low:
            selectedSegmentIndex = 0
        case .medium:
            selectedSegmentIndex = 1
        case .high:
            selectedSegmentIndex = 2
        }
        self.importanceSegmentedControl.selectedSegmentIndex = selectedSegmentIndex

        if let deadline = viewModel.deadline {
            self.deadlineSwitch.setOn(true, animated: true)
            self.deadlineButton.setTitle(self.dateFormatter.string(from: deadline), for: .normal)
            self.datePicker.setDate(deadline, animated: true)
            self.deadlineButton.isHidden = false
            datePicker.isHidden = false
        } else {
            self.deadlineSwitch.setOn(false, animated: true)
            self.deadlineButton.isHidden = true
            self.datePicker.isHidden = true
        }
    }

    @objc
    private func switchValueDidChange(_ sender: UISwitch) {
        if sender.isOn {
            let tomorrow = Date(timeIntervalSinceNow: Consts.oneDay)
            self.viewModel.deadline = tomorrow
            self.deadlineButton.setTitle(self.dateFormatter.string(from: tomorrow), for: .normal)
            self.datePicker.date = tomorrow
            self.deadlineButton.isHidden = false
        } else {
            self.deadlineButton.isHidden = true
            self.datePicker.isHidden = true
            self.viewModel.deadline = nil
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc
    private func onDateValueChanged(_ datePicker: UIDatePicker) {
        self.deadlineButton.setTitle(self.dateFormatter.string(from: datePicker.date), for: .normal)
        self.viewModel.deadline = datePicker.date
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc
    private func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        let importance: Importance
        switch self.importanceSegmentedControl.selectedSegmentIndex  {
        case 0:
            importance = .low
        case 1:
            importance = .medium
        case 2:
            importance = .high
        default:
            importance = .medium
        }
        self.viewModel.importance = importance
    }

    @objc
    private func deadlineButtonClicked(_ button: UIButton) {
        self.datePicker.isHidden = false
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc
    private func deleteButtonClicked(_ button: UIButton) {
        self.viewModel.didTapDelete?()
    }
}

extension TodoItemScrollView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.viewModel.text = textView.text
    }
}
