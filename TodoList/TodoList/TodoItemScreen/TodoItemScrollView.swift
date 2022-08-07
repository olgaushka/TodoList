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

    private let textView: UITextView
    private let containerView: UIView
    private let importanceLabel: UILabel
    private let dividerView: UIView
    private let deadlineLabel: UILabel
    private let segmentedControl: UISegmentedControl
    private let deadlineSwitch: UISwitch
    private let deadlineButton: UIButton
    private let datePicker: UIDatePicker
    private let deleteButton: UIButton

    private lazy var dateFormatter: DateFormatter = DateFormatter()

    override init(frame: CGRect) {
        self.viewModel = TodoItemScrollViewModel.makeDefault()
        
        self.textView = Self.makeTextView()
        self.containerView = Self.makeContainerView()
        self.importanceLabel = Self.makeImportanceLabel()
        self.segmentedControl = Self.makeSegmentedControl()
        self.dividerView = Self.makeDividerView()
        self.deadlineLabel = Self.makeDeadlineLabel()
        self.deadlineSwitch = Self.makeDeadlineSwitch()
        self.deadlineButton = Self.makeDeadlineButton()
        self.datePicker = Self.makeDatePicker()
        self.deleteButton = Self.makeDeleteButton()

        super.init(frame: frame)

        self.dateFormatter.dateFormat = "d MMMM yyyy"
        self.setupSubviews()
        self.updateView()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let test = UIDevice.current.orientation.isLandscape
        if UIDevice.current.orientation.isLandscape {
            print(self.bounds)
            textView.frame = .init(x: 16, y: 16, width: self.bounds.width - 32, height: self.bounds.height)
            self.containerView.isHidden = true
            self.deleteButton.isHidden = true

        } else {

            self.containerView.isHidden = false
            self.deleteButton.isHidden = false

            let textViewHeight = Consts.textViewHeight

            textView.frame = .init(x: 16, y: 16, width: self.bounds.width - 32, height: textViewHeight)
            var lastElementBottom = textView.frame.maxY

            self.containerView.frame.origin = .init(x: 16, y: lastElementBottom + 16)


            importanceLabel.sizeToFit()
            importanceLabel.frame.origin = .init(x: 16, y: 17)

            self.segmentedControl.frame.size = .init(width: 150, height: 36)
            self.segmentedControl.frame.origin = .init(x: containerView.bounds.width - 12 - segmentedControl.frame.width, y: 10)

            self.dividerView.frame = .init(x: 0, y: 56, width: containerView.bounds.width, height: 1)

            deadlineLabel.sizeToFit()
            deadlineLabel.frame.origin = .init(x: 16,
                                               y: dividerView.frame.maxY + 17)
            deadlineSwitch.sizeToFit()
            deadlineSwitch.frame.origin = .init(x: containerView.bounds.width - 12 - deadlineSwitch.frame.width,
                                               y: dividerView.frame.maxY + 12)
            deadlineButton.sizeToFit()
            deadlineButton.frame.origin = .init(x: 16,
                                               y: deadlineLabel.frame.maxY + 4)


            datePicker.sizeToFit()
            let ratio = datePicker.frame.size.height / datePicker.frame.size.width
            let datePickerSize = CGSize.init(width: self.containerView.bounds.width, height: self.containerView.bounds.width * ratio)
            self.datePicker.frame = .init(
                origin: .init(x: 0, y: deadlineButton.frame.maxY + 9),
                size: datePickerSize
            )

            let containerViewLastElementBottom: CGFloat
            if self.datePicker.isHidden {
                containerViewLastElementBottom = self.deadlineLabel.frame.maxY + 26
            } else {
                containerViewLastElementBottom = self.datePicker.frame.maxY
            }

            self.containerView.frame.size = .init(width: self.bounds.width - 32, height: containerViewLastElementBottom)

            lastElementBottom = self.containerView.frame.maxY

            deleteButton.frame.size = .init(width: self.bounds.width - 32, height: 56)
            deleteButton.frame.origin = .init(x: 16, y: lastElementBottom + 16)
            lastElementBottom = deleteButton.frame.maxY

            self.contentSize = .init(width: self.bounds.width, height: lastElementBottom)
        }
    }

    private enum Consts {
        static let textViewHeight: CGFloat = 120
    }

    private static func makeTextView() -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = .systemFont(ofSize: 17)
        textView.textContainerInset = .init(top: 16, left: 17, bottom: 17, right: 16)
        textView.layer.cornerRadius = 16
//        textView.text = "Что надо сделать?"
//        textView.textColor = UIColor.lightGray
        return textView
    }

    private static func makeContainerView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }

    private static func makeImportanceLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Важность"
        label.font = .systemFont(ofSize: 17)
        return label
    }

    private static func makeSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["\u{2193}", "нет", "\u{203C}"])
        control.selectedSegmentIndex = 1
        return control
    }

    private static func makeDividerView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemGray
        return view
    }

    private static func makeDeadlineLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Сделать до"
        label.font = .systemFont(ofSize: 17)
        return label
    }

    private static func makeDeadlineSwitch() -> UISwitch {
        let control = UISwitch(frame: .zero)
        return control
    }

    private static func makeDeadlineButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
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
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16

        return button
    }

    private func setupSubviews() {
        addSubview(self.textView)
        textView.delegate = self

        addSubview(self.containerView)
        self.containerView.addSubview(self.importanceLabel)
        self.containerView.addSubview(self.segmentedControl)
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        self.containerView.addSubview(self.dividerView)
        self.containerView.addSubview(self.deadlineLabel)
        self.containerView.addSubview(self.deadlineSwitch)
        deadlineSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        self.containerView.addSubview(self.deadlineButton)
        self.deadlineButton.addTarget(self, action: #selector(deadlineButtonClicked(_:)), for: .touchUpInside)

        self.containerView.addSubview(self.datePicker)
        self.datePicker.addTarget(self, action: #selector(onDateValueChanged(_:)), for: .valueChanged)

        addSubview(self.deleteButton)
        self.deleteButton.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
    }

    private func updateView() {
        let viewModel = self.viewModel

        self.textView.text = viewModel.text

        let selectedSegmentIndex: Int
        switch viewModel.importance {
        case .low:
            selectedSegmentIndex = 0
        case .medium:
            selectedSegmentIndex = 1
        case .high:
            selectedSegmentIndex = 2
        }
        self.segmentedControl.selectedSegmentIndex = selectedSegmentIndex

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
            print("on")
            let tomorrow = Date(timeIntervalSinceNow: 24 * 60 * 60)
            self.viewModel.deadline = tomorrow
            self.deadlineButton.setTitle(self.dateFormatter.string(from: tomorrow), for: .normal)
            self.datePicker.date = tomorrow
            self.deadlineButton.isHidden = false
        } else {
            print("off")
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
        switch self.segmentedControl.selectedSegmentIndex  {
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
