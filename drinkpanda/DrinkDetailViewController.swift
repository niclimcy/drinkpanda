//
//  DrinkDetailViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import MapKit
import UIKit

protocol DrinkDetailViewControllerDelegate: AnyObject {
    func didUpdateDrink(_ drink: Drink)
}

class DrinkDetailViewController: UITableViewController,
    DrinkFormViewControllerDelegate
{
    weak var delegate: DrinkDetailViewControllerDelegate?

    private static let imageCardCellIdentifier = "ImageCardCell"
    private static let storeCellIdentifier = "StoreCell"
    private static let dateCellIdentifier = "DateCell"
    private static let mapCellIdentifier = "MapCell"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    var drink: Drink?

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerRadius = 12
        mapView.clipsToBounds = true
        mapView.translatesAutoresizingMaskIntoConstraints = false

        return mapView
    }()

    private let drinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    // Grey backdrop shown behind the placeholder symbol (no photo).
    private let placeholderBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
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

    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let storeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Store"
        label.font = .preferredFont(forTextStyle: .body)

        return label
    }()

    private let storeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 0

        return label
    }()

    private let storeRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = .preferredFont(forTextStyle: .body)

        return label
    }()

    private let dateValueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .right

        return label
    }()

    private let dateRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    init(drink: Drink) {
        self.drink = drink
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.imageCardCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.storeCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.dateCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.mapCellIdentifier
        )
        updateUI()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return drink?.coordinate == nil ? 1 : 2
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 1:
            return "Location Information"
        case 2:
            return "Date Visited"
        default:
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return imageCardCell(for: indexPath)
        case (1, 0):
            return storeCell(for: indexPath)
        case (1, 1):
            return mapCell(for: indexPath)
        case (2, 0):
            return dateCell(for: indexPath)
        default:
            return UITableViewCell()
        }
    }

    private func imageCardCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.imageCardCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(drinkImageView) {
            textStack.addArrangedSubview(nameLabel)
            textStack.addArrangedSubview(scoreLabel)
            textStack.addArrangedSubview(reviewLabel)

            cell.contentView.addSubview(placeholderBackground)
            cell.contentView.addSubview(drinkImageView)
            cell.contentView.addSubview(textStack)

            let imageHeight = drinkImageView.heightAnchor.constraint(
                equalToConstant: 300
            )
            imageHeight.priority = .defaultHigh

            NSLayoutConstraint.activate([
                // Borderless: image touches the card's top and side edges.
                drinkImageView.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor
                ),
                drinkImageView.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor
                ),
                drinkImageView.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor
                ),
                imageHeight,

                placeholderBackground.topAnchor.constraint(
                    equalTo: drinkImageView.topAnchor
                ),
                placeholderBackground.leadingAnchor.constraint(
                    equalTo: drinkImageView.leadingAnchor
                ),
                placeholderBackground.trailingAnchor.constraint(
                    equalTo: drinkImageView.trailingAnchor
                ),
                placeholderBackground.bottomAnchor.constraint(
                    equalTo: drinkImageView.bottomAnchor
                ),

                textStack.topAnchor.constraint(
                    equalTo: drinkImageView.bottomAnchor,
                    constant: 16
                ),
                textStack.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor,
                    constant: 16
                ),
                textStack.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor,
                    constant: -16
                ),
                textStack.bottomAnchor.constraint(
                    equalTo: cell.contentView.bottomAnchor,
                    constant: -16
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

        if !cell.contentView.subviews.contains(storeRow) {
            storeTitleLabel.setContentHuggingPriority(
                .required,
                for: .horizontal
            )
            storeRow.addArrangedSubview(storeTitleLabel)
            storeRow.addArrangedSubview(storeValueLabel)
            cell.contentView.addSubview(storeRow)

            NSLayoutConstraint.activate([
                storeRow.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor
                ),
                storeRow.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor
                ),
                storeRow.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                storeRow.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor
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

        if !cell.contentView.subviews.contains(dateRow) {
            dateTitleLabel.setContentHuggingPriority(
                .required,
                for: .horizontal
            )
            dateRow.addArrangedSubview(dateTitleLabel)
            dateRow.addArrangedSubview(dateValueLabel)
            cell.contentView.addSubview(dateRow)

            NSLayoutConstraint.activate([
                dateRow.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor
                ),
                dateRow.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor
                ),
                dateRow.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                dateRow.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor
                ),
            ])
        }
        return cell
    }

    private func mapCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.mapCellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        if !cell.contentView.subviews.contains(mapView) {
            cell.contentView.addSubview(mapView)

            NSLayoutConstraint.activate([
                mapView.leadingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor
                ),
                mapView.trailingAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor
                ),
                mapView.topAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.topAnchor
                ),
                mapView.bottomAnchor.constraint(
                    equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor
                ),
                mapView.heightAnchor.constraint(equalToConstant: 200),
            ])
        }
        return cell
    }

    private func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        guard let coordinate = drink?.coordinate else { return }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = drink?.storeName
        mapView.addAnnotation(annotation)
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ),
            animated: false
        )
        mapView.selectAnnotation(annotation, animated: false)
    }

    @objc func editTapped() {
        let vc = DrinkFormViewController(drink: drink)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    func didUpdateDrink(_ drink: Drink) {
        self.drink = drink
        updateUI()
        delegate?.didUpdateDrink(drink)
    }

    private func updateUI() {
        title = drink?.name ?? "Details"

        if let image = drink?.image {
            drinkImageView.image = image
            drinkImageView.contentMode = .scaleAspectFill
            placeholderBackground.isHidden = true
        } else {
            let config = UIImage.SymbolConfiguration(
                pointSize: 50,
                weight: .light
            )
            drinkImageView.image = UIImage(
                systemName: "cup.and.saucer.fill",
                withConfiguration: config
            )
            drinkImageView.contentMode = .center
            drinkImageView.tintColor = .systemGray3
            placeholderBackground.isHidden = false
        }

        nameLabel.text = drink?.name ?? "-"
        scoreLabel.text = "★ \(drink?.score ?? 0)"

        let review = drink?.review ?? ""
        reviewLabel.text = review
        reviewLabel.isHidden = review.isEmpty

        storeValueLabel.text = drink?.storeName ?? "-"
        dateValueLabel.text =
            drink?.date.map { Self.dateFormatter.string(from: $0) } ?? "-"

        updateMap()
        tableView.reloadData()
    }
}
