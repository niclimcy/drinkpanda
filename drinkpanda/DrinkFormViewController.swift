//
//  DrinkFormViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import UIKit

protocol DrinkFormViewControllerDelegate: AnyObject {
    func didAddDrink(_ drink: Drink)
    func didUpdateDrink(_ drink: Drink)
}

extension DrinkFormViewControllerDelegate {
    func didAddDrink(_ drink: Drink) {}
    func didUpdateDrink(_ drink: Drink) {}
}

class DrinkFormViewController: UITableViewController, UITextViewDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var drink: Drink?
    weak var delegate: DrinkFormViewControllerDelegate?

    private static let nameCellIdentifier = "NameCell"
    private static let reviewCellIdentifier = "ReviewCell"
    private static let scoreCellIdentifier = "ScoreCell"
    private static let imageCellIdentifier = "ImageCell"
    private static let storeCellIdentifier = "StoreCell"
    private static let dateCellIdentifier = "DateCell"

    private let nameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.textAlignment = .natural
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()

    private let reviewTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .natural
        textView.font = .preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false

        return textView
    }()

    private let reviewPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Review"
        label.textColor = .placeholderText
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "★ 5"
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let scoreStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.maximumValue = 10
        stepper.minimumValue = 1
        stepper.value = 5
        stepper.translatesAutoresizingMaskIntoConstraints = false

        return stepper
    }()

    private let scoreRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let imageStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .systemGray5
        imageView.layer.borderColor = UIColor.systemBackground.cgColor

        // Default placeholder
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let placeholderImage = UIImage(
            systemName: "cup.and.saucer",
            withConfiguration: config
        )
        imageView.image = placeholderImage
        imageView.tintColor = .systemGray3

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let imageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.prominentClearGlass()
        config.title = "Change Photo"
        config.image = UIImage(systemName: "photo")
        config.imagePadding = 8
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let storeField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Store"
        textField.textAlignment = .natural
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()

    private let dateStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = "Date of visit"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.accessibilityLabel = "Date of visit"
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        return datePicker
    }()

    init(drink: Drink? = nil) {
        self.drink = drink
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a new drink"
        self.sheetPresentationController?.prefersGrabberVisible = true

        // MARK: - Navigation Controls
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.nameCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.reviewCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.scoreCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.imageCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.storeCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.dateCellIdentifier
        )
        configureReviewPlaceholder()
        configureForEditing(drink: self.drink)
    }

    private func configureReviewPlaceholder() {
        reviewTextView.delegate = self
        reviewTextView.addSubview(reviewPlaceholderLabel)

        NSLayoutConstraint.activate([
            reviewPlaceholderLabel.leadingAnchor.constraint(
                equalTo: reviewTextView.frameLayoutGuide.leadingAnchor
            ),
            reviewPlaceholderLabel.topAnchor.constraint(
                equalTo: reviewTextView.frameLayoutGuide.topAnchor
            ),
        ])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return nameCell(for: indexPath)
        case (0, 1):
            return reviewCell(for: indexPath)
        case (0, 2):
            return scoreCell(for: indexPath)
        case (0, 3):
            return imageCell(for: indexPath)
        case (1, 0):
            return storeCell(for: indexPath)
        case (1, 1):
            return dateCell(for: indexPath)
        default:
            return UITableViewCell()
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0:
            return "Review"
        case 1:
            return "Additional Information"
        default:
            return nil
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        reviewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    private func setupKeyboardDismissal() {
        // Add tap gesture to dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false  // Allow other views to still receive touches
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configureForEditing(drink: Drink?) {
        guard let drink else { return }
        title = "Edit existing review"

        // TODO: Edit labels
        nameField.text = drink.name
        reviewTextView.text = drink.review
        reviewPlaceholderLabel.isHidden = !reviewTextView.text.isEmpty
        scoreLabel.text = "★ \(drink.score)"
        scoreStepper.value = Double(drink.score)
        imageView.image = drink.image
        storeField.text = drink.storeName
        datePicker.date = drink.date ?? Date()
    }

    private func nameCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.nameCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(nameField) {
            cell.contentView.addSubview(nameField)

            NSLayoutConstraint.activate([
                nameField.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .leadingAnchor
                ),
                nameField.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .trailingAnchor
                ),
                nameField.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                nameField.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .bottomAnchor
                ),
            ])
        }
        return cell
    }

    private func reviewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.reviewCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(reviewTextView) {
            cell.contentView.addSubview(reviewTextView)

            NSLayoutConstraint.activate([
                reviewTextView.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor
                ),
                reviewTextView.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor
                ),
                reviewTextView.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                reviewTextView.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor
                ),
                reviewTextView.heightAnchor.constraint(
                    greaterThanOrEqualToConstant: 88
                ),
            ])
        }
        return cell
    }

    private func scoreCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.scoreCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(scoreStepper) {
            scoreRow.addArrangedSubview(scoreLabel)
            scoreRow.addArrangedSubview(scoreStepper)
            scoreStepper.addAction(
                UIAction(handler: { [weak self] action in
                    guard let self,
                        let currentStepper = action.sender as? UIStepper
                    else {
                        return
                    }

                    scoreLabel.text =
                        "★ \(String(format: "%.0f", currentStepper.value))"
                }),
                for: .valueChanged
            )

            cell.contentView.addSubview(scoreRow)

            NSLayoutConstraint.activate([
                scoreRow.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .leadingAnchor
                ),
                scoreRow.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .trailingAnchor
                ),
                scoreRow.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                scoreRow.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .bottomAnchor
                ),
            ])
        }
        return cell
    }

    private func imageCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.imageCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(imageStack) {
            imageStack.addArrangedSubview(imageView)
            imageStack.addArrangedSubview(imageButton)

            imageButton.addTarget(
                self,
                action: #selector(imageButtonTapped),
                for: .touchUpInside
            )

            cell.contentView.addSubview(imageStack)

            NSLayoutConstraint.activate([
                imageStack.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .leadingAnchor
                ),
                imageStack.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .trailingAnchor
                ),
                imageStack.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                imageStack.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .bottomAnchor
                ),
                imageView.heightAnchor.constraint(
                    equalToConstant: 300
                ),
            ])
        }
        return cell
    }

    private func storeCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.storeCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(storeField) {
            cell.contentView.addSubview(storeField)

            NSLayoutConstraint.activate([
                storeField.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .leadingAnchor
                ),
                storeField.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .trailingAnchor
                ),
                storeField.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                storeField.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .bottomAnchor
                ),
            ])
        }
        return cell
    }

    private func dateCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.dateCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(dateStack) {
            dateStack.addArrangedSubview(dateLabel)
            dateStack.addArrangedSubview(datePicker)
            cell.contentView.addSubview(dateStack)

            NSLayoutConstraint.activate([
                dateStack.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .leadingAnchor
                ),
                dateStack.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .trailingAnchor
                ),
                dateStack.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                dateStack.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide
                        .bottomAnchor
                ),
            ])
        }
        return cell
    }

    @objc private func cancelTapped() {
        self.dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let name = nameField.text ?? ""
        let review = reviewTextView.text ?? ""
        let score = Int(scoreStepper.value)
        let store = storeField.text ?? ""
        let date = datePicker.date
        let image = imageView.image

        if let existingDrink = self.drink {
            existingDrink.name = name
            existingDrink.review = review
            existingDrink.score = score
            existingDrink.storeName = store
            existingDrink.date = date
            existingDrink.image = image

            delegate?.didUpdateDrink(existingDrink)
        } else {
            let newDrink = Drink(
                name: name,
                storeName: store,
                score: score,
                review: review,
                date: date,
                image: image
            )

            delegate?.didAddDrink(newDrink)
        }

        dismiss(animated: true)
    }

    private func presentImagePicker(
        sourceType: UIImagePickerController.SourceType
    ) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func imageButtonTapped() {
        let alert = UIAlertController(
            title: "Choose a photo",
            message: nil,
            preferredStyle: .actionSheet
        )
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(
                UIAlertAction(
                    title: "Choose from Library",
                    style: .default,
                    handler: { (alert: UIAlertAction!) in
                        self.presentImagePicker(sourceType: .photoLibrary)
                    }
                )
            )
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = imageButton
        }

        present(alert, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:
            Any]
    ) {
        let selectedImage =
            (info[.editedImage] as? UIImage)
            ?? (info[.originalImage] as? UIImage)
        imageView.image = selectedImage
        imageView.contentMode = .scaleAspectFill
        picker.dismiss(animated: true)
    }

    // Just dismiss the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
