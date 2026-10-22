//
//  StoreSearchViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import MapKit
import UIKit

/// Searches Apple Maps for a store and reports back its name and coordinate.
class StoreSearchViewController: UITableViewController, UISearchResultsUpdating,
    MKLocalSearchCompleterDelegate
{
    var initialQuery: String?
    var onSelect: ((String, CLLocationCoordinate2D) -> Void)?

    private static let cellIdentifier = "ResultCell"

    private let completer: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.resultTypes = .pointOfInterest
        return completer
    }()
    private var results: [MKLocalSearchCompletion] = []
    private let searchController = UISearchController(
        searchResultsController: nil
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Store"

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.cellIdentifier
        )

        completer.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Apple Maps"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        if let query = initialQuery?.trimmingCharacters(in: .whitespaces),
            !query.isEmpty
        {
            searchController.searchBar.text = query
            completer.queryFragment = query
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Search

    func updateSearchResults(for searchController: UISearchController) {
        completer.queryFragment = searchController.searchBar.text ?? ""
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        tableView.reloadData()
    }

    func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        results = []
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        results.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.cellIdentifier,
            for: indexPath
        )
        let result = results[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = result.title
        content.secondaryText = result.subtitle
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Resolve the completion into a full map item to get its coordinate.
        let request = MKLocalSearch.Request(completion: results[indexPath.row])
        MKLocalSearch(request: request).start { [weak self] response, _ in
            guard let item = response?.mapItems.first else { return }
            // Only the name and lat/long are kept; the rest of the map item is dropped.
            self?.onSelect?(item.name ?? "", item.location.coordinate)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
