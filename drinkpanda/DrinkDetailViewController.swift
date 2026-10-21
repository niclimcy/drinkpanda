//
//  DrinkDetailViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import UIKit

class DrinkDetailViewController: UITableViewController,
    DrinkFormViewControllerDelegate
{
    private enum Section: Int, CaseIterable {
        case imageCard
        case informationCard

        var title: String? {
            switch self {
            case .imageCard: return nil
            case .informationCard: return "Additional Information"
            }
        }
    }

    private enum InformationRow: Int, CaseIterable {
        case store
        case date
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )
        title = drink?.name ?? "Details"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(
            DrinkImageCardCell.self,
            forCellReuseIdentifier: DrinkImageCardCell.identifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.cellIdentifier
        )
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
        case .imageCard: return 1
        case .informationCard: return InformationRow.allCases.count
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
        switch Section(rawValue: indexPath.section) {
        case .imageCard:
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: DrinkImageCardCell.identifier,
                    for: indexPath
                ) as! DrinkImageCardCell
            cell.configure(with: drink)
            return cell
        case .informationCard, .none:
            return informationCell(for: indexPath)
        }
    }

    private func informationCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.cellIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none

        var content = cell.defaultContentConfiguration()
        switch InformationRow(rawValue: indexPath.row) {
        case .store:
            content.text = "Store"
            content.secondaryText = drink?.storeName ?? "-"
        case .date:
            content.text = "Date"
            content.secondaryText =
                drink?.date.map { Self.dateFormatter.string(from: $0) } ?? "-"
        case .none:
            break
        }
        content.secondaryTextProperties.color = .secondaryLabel
        content.prefersSideBySideTextAndSecondaryText = true
        cell.contentConfiguration = content
        return cell
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
    }

    private func updateUI() {
        // TODO: Update drink labels
    }
}
