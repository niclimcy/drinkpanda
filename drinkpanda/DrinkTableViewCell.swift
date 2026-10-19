//
//  DrinkTableViewCell.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {
    static let identifier = "drink"

    // MARK: - Properties
    var drink: Drink?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private let cellStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .tertiaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 28,
            weight: .medium
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel = DrinkTableViewCell.makeLabel(
        style: .headline,
        color: .label,
        lines: 2
    )

    private let storeLabel = DrinkTableViewCell.makeLabel(
        style: .subheadline,
        color: .secondaryLabel,
        lines: 2
    )

    private let notesLabel = DrinkTableViewCell.makeLabel(
        style: .footnote,
        color: .secondaryLabel,
        lines: 2
    )

    private let dateLabel = DrinkTableViewCell.makeLabel(
        style: .caption1,
        color: .tertiaryLabel
    )

    private let scoreLabel: UILabel = {
        let label = DrinkTableViewCell.makeLabel(
            style: .headline,
            color: .systemPink
        )
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(storeLabel)
        textStack.addArrangedSubview(notesLabel)
        textStack.addArrangedSubview(dateLabel)

        cellStack.addArrangedSubview(thumbnailView)
        cellStack.addArrangedSubview(textStack)
        cellStack.addArrangedSubview(scoreLabel)
        contentView.addSubview(cellStack)

        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cellStack.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            cellStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            cellStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            cellStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -12
            ),

            thumbnailView.widthAnchor.constraint(equalToConstant: 72),
            thumbnailView.heightAnchor.constraint(equalToConstant: 72),
        ])
    }

    func configure(with drink: Drink) {
        self.drink = drink

        if let image = drink.image {
            thumbnailView.image = image
            thumbnailView.contentMode = .scaleAspectFill
        } else {
            thumbnailView.image = UIImage(systemName: "cup.and.saucer.fill")
            thumbnailView.contentMode = .center
        }

        nameLabel.text = drink.name
        storeLabel.text = drink.storeName
        scoreLabel.text = "★ \(drink.score)"

        notesLabel.text = drink.notes
        notesLabel.isHidden = drink.notes.isEmpty

        if let date = drink.date {
            dateLabel.text = DrinkTableViewCell.dateFormatter.string(from: date)
            dateLabel.isHidden = false
        } else {
            dateLabel.isHidden = true
        }
    }

    private static func makeLabel(
        style: UIFont.TextStyle,
        color: UIColor,
        lines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.numberOfLines = lines
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
