//
//  DrinkDetailViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import UIKit

class DrinkDetailViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case image
        case information
        case rating

        var title: String {
            switch self {
            case .image: return ""
            case .information: return "Information"
            case .rating: return "Rating"
            }
        }
    }

    private enum InformationRow: Int, CaseIterable {
        case name
        case store
        case date
    }

    private enum RatingRow: Int, CaseIterable {
        case score
        case review
    }

    private static let cellIdentifier = "DrinkDetailCell"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    var drink: Drink?

    init(drink: Drink) {
        self.drink = drink
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        title = drink?.name ?? "Details"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch Section(rawValue: section) {
        case .image: return 1
        case .information: return InformationRow.allCases.count
        case .rating: return RatingRow.allCases.count
        case .none: return 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return Section(rawValue: section)?.title
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == .image {
            return imageCell()
        }

        let cell = UITableViewCell(
            style: .value1,
            reuseIdentifier: Self.cellIdentifier
        )
        var content = cell.defaultContentConfiguration()
        var detail = ""

        switch Section(rawValue: indexPath.section) {
        case .image:
            break
        case .information:
            switch InformationRow(rawValue: indexPath.row) {
            case .name:
                content.text = "Name"
                detail = drink?.name ?? "-"
            case .store:
                content.text = "Store"
                detail = drink?.storeName ?? "-"
            case .date:
                content.text = "Date"
                detail =
                    drink?.date.map { Self.dateFormatter.string(from: $0) }
                    ?? "-"
            case .none:
                break
            }
        case .rating:
            switch RatingRow(rawValue: indexPath.row) {
            case .score:
                content.text = "★ Score"
                let score = drink?.score ?? 0
                detail = "\(score)"
            case .review:
                content.text = "¶ Review"
                detail = drink?.review ?? "-"
            case .none:
                break
            }
        case .none:
            break
        }

        content.secondaryText = detail
        content.secondaryTextProperties.color = .secondaryLabel
        content.prefersSideBySideTextAndSecondaryText = true
        cell.contentConfiguration = content
        return cell
    }

    private func imageCell() -> UITableViewCell {
        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: Self.cellIdentifier
        )
        cell.selectionStyle = .none

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let image = drink?.image {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "cup.and.saucer")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .secondaryLabel
        }

        cell.contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: cell.contentView.topAnchor
            ),
            imageView.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: cell.contentView.trailingAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: cell.contentView.bottomAnchor
            ),
            imageView.heightAnchor.constraint(equalToConstant: 300),
        ])

        return cell
    }
}
