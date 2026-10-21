//
//  DrinkImageCardCell.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 21/10/26.
//

import UIKit

class DrinkImageCardCell: UITableViewCell {
    static let identifier = "drinkCard"

    private let drinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [
            nameLabel, scoreLabel, reviewLabel,
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(drinkImageView)
        contentView.addSubview(textStack)

        let imageHeight = drinkImageView.heightAnchor.constraint(
            equalToConstant: 300
        )
        imageHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            // Borderless: image touches the card's top and side edges.
            drinkImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            drinkImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            drinkImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            imageHeight,

            textStack.topAnchor.constraint(
                equalTo: drinkImageView.bottomAnchor,
                constant: 16
            ),
            textStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            textStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            textStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            ),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with drink: Drink?) {
        if let image = drink?.image {
            drinkImageView.image = image
            drinkImageView.contentMode = .scaleAspectFill
        } else {
            drinkImageView.image = UIImage(systemName: "cup.and.saucer")
            drinkImageView.contentMode = .scaleAspectFit
            drinkImageView.tintColor = .secondaryLabel
        }

        nameLabel.text = drink?.name ?? "-"
        scoreLabel.text = "★ \(drink?.score ?? 0)"

        let review = drink?.review ?? ""
        reviewLabel.text = review
        reviewLabel.isHidden = review.isEmpty
    }
}
