//
//  ViewController.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, UISearchBarDelegate, DrinkFormViewControllerDelegate
{
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    private var drinks = [
        Drink(
            name: "Matcha Latte",
            storeName: "Chagee - Punggol Coast Mall",
            score: 8,
            review: "Good flavour",
            date: Calendar.current.date(
                from: DateComponents(year: 2026, month: 9, day: 8)
            ),
            image: UIImage(named: "ChageeMatcha")
        ),
        Drink(
            name: "Matcha Latte",
            storeName: "Creamie Sippies - Jewel",
            score: 7,
            review: "Very grassy",
            date: Calendar.current.date(
                from: DateComponents(year: 2026, month: 9, day: 13)
            ),
            image: UIImage(named: "CreamieSippiesMatcha")
        ),
        Drink(
            name: "913 King's Oolong Milk Tea",
            storeName: "TenRen’s Tea - The Star Vista",
            score: 6,
            review: "Very fragrant",
            date: Calendar.current.date(
                from: DateComponents(year: 2026, month: 10, day: 10)
            ),
            image: UIImage(named: "TenrenKingOolong")
        ),
    ]
    private var filteredDrinks: [Drink] = []
    private var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "🐼 drinkpanda"

        setupNavBar()
        setupTableView()
        setupToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemPink
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        guard let bar = navigationController?.navigationBar else { return }
        bar.prefersLargeTitles = true
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.tintColor = .white
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            DrinkTableViewCell.self,
            forCellReuseIdentifier: DrinkTableViewCell.identifier
        )
    }

    private func setupToolbar() {
        navigationController?.setToolbarHidden(false, animated: false)

        searchBar.placeholder = "Search drinks"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchBar.sizeToFit()

        let searchItem = UIBarButtonItem(customView: searchBar)

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let addItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )

        toolbarItems = [searchItem, flexibleSpace, addItem]
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        isSearching ? filteredDrinks.count : drinks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DrinkTableViewCell.identifier,
                for: indexPath
            ) as? DrinkTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(
            with: isSearching
                ? filteredDrinks[indexPath.row] : drinks[indexPath.row]
        )
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // TODO: show DrinkDetailViewController
        let vc = DrinkDetailViewController(
            drink: isSearching
                ? filteredDrinks[indexPath.row] : drinks[indexPath.row]
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        100
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            drinks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredDrinks = drinks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.storeName.localizedCaseInsensitiveContains(searchText)
            }
        }

        tableView.reloadData()
    }

    @objc func addButtonTapped() {
        let vc = DrinkFormViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    func didAddDrink(_ drink: Drink) {
        drinks.append(drink)
        tableView.reloadData()
    }
}

#Preview {
    UINavigationController(rootViewController: ListViewController())
}
