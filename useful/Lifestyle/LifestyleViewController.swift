//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Lottie
import Combine
import ComposableArchitecture
import UIKit

final class LifestyleViewController: UIViewController {
    private let viewStore: ViewStoreOf<LifestyleFeature>
    private var cancellables: Set<AnyCancellable> = []

    init(store: StoreOf<LifestyleFeature>) {
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var dataSource: UICollectionViewDiffableDataSource<LifestyleSectionType, DisposableItem>! = nil

    // Collection view and related view

    private lazy var eventView = EventView(contentVerticalInset: Constants.contentTopInset)
    private var eventViewConstraints: [NSLayoutConstraint] = []

    private lazy var refreshControl: UIRefreshControl = mutate(UIRefreshControl()) {
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(refreshItems(_:)), for: .valueChanged)
    }

    private lazy var collectionView: UICollectionView =
        mutate(UICollectionView(frame: .zero, collectionViewLayout: createLayout())) {
            $0.contentInset.top = Constants.contentTopInset
            $0.refreshControl = self.refreshControl
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.register(ItemCell.self)
            $0.register(SuggestedItemsCell.self)
            $0.register(TitleSupplementaryView.self, kind: .header)
            $0.backgroundColor = UIColor(collection: .background)
        }

    // -- Collection view and related view --

    private let searchController = UISearchController(searchResultsController: nil)

    private var elasticTopInset: CGFloat = 0 {
        didSet {
            calendarContainerTopConstraint?.constant = elasticTopInset
            calendarBarHeaderTopConstraint?.constant = elasticTopInset
        }
    }

    private let calendarBar = CalendarBar()
    private var calendarAnimator: CalendarAnimator?

    private var calendarContainerTopConstraint: NSLayoutConstraint?
    private var calendarBarHeaderTopConstraint: NSLayoutConstraint?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Lifestyle"
        view.backgroundColor = UIColor(collection: .primary)
        configureHierarchy()
        configureDataSource()
        configureCalendarBar()

        setupBindings()

        viewStore.send(.onViewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        navigationItem.searchController = searchController
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureSearchBar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - New Logic

    private func setupBindings() {
        viewStore.publisher
            .disposableItems
            .sink { [weak self] in
                self?.refresh(sections: $0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .loadInfo
            .sink { [weak self] in
                self?.loadingDisposableItems(with: $0)
            }
            .store(in: &cancellables)
    }

    private func refresh(sections: [LifestyleSection], animatingDifferences: Bool = true) {
        guard !sections.isEmpty else {

            configureBackgroundView(for: .empty)
            dataSource.apply(
                NSDiffableDataSourceSnapshot<LifestyleSectionType, DisposableItem>(),
                animatingDifferences: animatingDifferences
            )
            return
        }

        collectionView.backgroundView = nil
        var snapshot = NSDiffableDataSourceSnapshot<LifestyleSectionType, DisposableItem>()
        sections.forEach {
            snapshot.appendSections([$0.section])
            snapshot.appendItems($0.items)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    // MARK: - End New Logic

    private func loadingDisposableItems(with info: LoadInfo) {
        switch info.state {
        case .willLoad:
            guard info.type == .loadNew else { break }
            LoaderView.shared.start(in: view) { [weak self] in
                guard let self = self else { return }
                view.insertSubview($0, aboveSubview: self.collectionView)
            }
        case .failLoading:
            LoaderView.shared.stop()
            refreshControl.endRefreshing()
            configureBackgroundView(for: .error)
        case .didLoad:
            LoaderView.shared.stop()
            refreshControl.endRefreshing()
            refresh(sections: viewStore.disposableItems, animatingDifferences: true)
        case .isLoading: break
        }
    }

    @objc
    private func refreshItems(_: UIRefreshControl) {
        viewStore.send(.refreshControlTriggered)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        refresh(sections: viewStore.disposableItems, animatingDifferences: false)
    }
}

extension LifestyleViewController {

    private func configureCalendarBar() {

        // -- Container view --
        // Helps to handle collection view oscillation

        let containerView = UIView.create(
            backgroundColor: UIColor(collection: .primary),
            cornerRadius: Constants.calendarContainerCornerRadius
        )
        view.addSubview(containerView)
        let containerConstraints = NSLayoutConstraint.snap(containerView, to: collectionView, for: [.left, .right, .top])
        if let containerTopConstraint = containerConstraints[.top] {
            calendarContainerTopConstraint = containerTopConstraint
        }

        // -- Calendar header --

        let titleBackgroundView = UIView.create(backgroundColor: UIColor(collection: .primary))
        let titleLabel = UILabel.create(fontStyle: .headline, textColor: .white)
        titleLabel.text = Date().formatted(as: .custom(style: .monthYear, timeZone: .current))

        view.insertSubview(titleBackgroundView, aboveSubview: calendarBar)
        NSLayoutConstraint.snap(titleBackgroundView, to: view, for: [.left, .right])

        titleBackgroundView.addSubview(titleLabel)
        NSLayoutConstraint.snap(titleLabel, to: titleBackgroundView, for: [.top, .right, .bottom], with: Constants.titleInsets)
        titleLabel.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Constants.titleInsets.left
        ).activate()

        let topHeaderConstraint = titleBackgroundView.topAnchor.constraint(equalTo: collectionView.topAnchor)
        calendarBarHeaderTopConstraint = topHeaderConstraint
        topHeaderConstraint.activate()

        // -- Calendar --

        containerView.addSubview(calendarBar)
        calendarBar.delegate = self

        let calendarConstraint = NSLayoutConstraint.snap(
            calendarBar,
            to: containerView,
            for: [.left, .right, .top],
            sizeAttributes: [.height(value: Constants.calendarHeight)],
            with: .create(top: Constants.calendarInset)
        )

        // make container view same height as a calendar bar visible portion
        containerView.bottomAnchor.constraint(equalTo: calendarBar.bottomAnchor).activate(with: .defaultLow)

        if let calendarTopConstraint = calendarConstraint[.top] {
            calendarAnimator = CalendarAnimator(
                inset: Constants.calendarInset,
                constraint: calendarTopConstraint,
                calendar: calendarBar
            )
        }
    }

    private func configureSearchBar() {
        mutate(searchController.searchBar) {
            $0.searchTextField.textColor = .white
            $0.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            $0.tintColor = .white
            $0.searchTextField.attributedPlaceholder = NSAttributedString(
                string: "Search items",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
            )

            mutate($0.searchTextField.leftView as? UIImageView) { searchGlyph in
                searchGlyph?.image = searchGlyph?.image?.withRenderingMode(.alwaysTemplate)
                searchGlyph?.tintColor = .white
            }

            ($0.searchTextField.value(forKey: "clearButton") as? UIButton).map { clearButton in
                clearButton.imageView?.tintColor = .white

                let configuration = UIImage.SymbolConfiguration(scale: .medium)
                let clearGlyph = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)

                clearButton.setImage(clearGlyph?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }

    private func configureBackgroundView(for event: EventView.EventType) {

        eventView.removeConstraints(eventViewConstraints)
        eventView.configure(for: event)
        collectionView.backgroundView = eventView

        let sideConstraint = NSLayoutConstraint.snap(eventView, to: view, for: [.left, .right, .bottom])
        let topConstraint = eventView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        eventViewConstraints = Array(sideConstraint.values) + [topConstraint]
    }
}

extension LifestyleViewController {

    private func createLayout() -> UICollectionViewLayout {

        let layout =
            UICollectionViewCompositionalLayout { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

                // --- Item ---

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // --- Group ---

                let traitCollection = layoutEnvironment.traitCollection

                var columns = 0
                switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
                case (.compact, .compact), (.regular, _):
                    columns = 4
                default:
                    columns = 2
                }
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(Constants.estimatedGroupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
                group.interItemSpacing = .fixed(Constants.interItemSpacing)

                // --- Section ---

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.interItemSpacing
                section.contentInsets = Constants.sectionInsets

                // --- Header ---

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(Constants.estimatedHeaderHeight)
                )
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: SupplementaryViewKind.header.kindIdentifier(TitleSupplementaryView.self), alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            }
        return layout
    }
}

extension LifestyleViewController {

    private func configureHierarchy() {
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.snap(collectionView, to: view, for: [.left, .right, .bottom])
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<
            LifestyleSectionType,
            DisposableItem
        >(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, disposableItem: DisposableItem) -> UICollectionViewCell? in

                guard let self = self else { return nil }

                let content = self.viewStore.disposableItems[indexPath.section]

                // print("The identifier is \(disposableItem) the index path is \(indexPath)")

                let isLast = disposableItem == self.viewStore.disposableItems[indexPath.section].items.last

                // If last item in a first section
                if isLast, content.section == .ongoing {

                    let cell: SuggestedItemsCell = collectionView.dequeueReusableCell(for: indexPath)
                    cell.configure(items: Int.random(in: 2..<10))
                    return cell
                } else {

                    let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
                    cell.configure(
                        name: disposableItem.name,
                        imageURL: disposableItem.imageURL,
                        imageURLDark: disposableItem.imageURLDark,
                        isCompleted: disposableItem.isCompleted == true
                    )
                    return cell
                }
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self else { return nil }

            let section = self.viewStore.disposableItems[indexPath.section].section
            let supplementaryView: TitleSupplementaryView = collectionView.dequeueReusableSupplementaryView(
                for: indexPath,
                kind: kind
            )

            supplementaryView.configure(header: ("Test", "Test"))

            return supplementaryView
        }
    }
}

extension LifestyleViewController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_: UIScrollView) {
        calendarAnimator?.closeBar()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Helps to mimic the behaviour of the stretchy navigation bar
        let isNegativeDirection = scrollView.contentOffset.y <= -Constants.contentTopInset
        elasticTopInset = isNegativeDirection ? abs(scrollView.contentOffset.y) - Constants.contentTopInset : 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let underConstruction = UnderConstructionViewController()
        present(underConstruction, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension LifestyleViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewStore.send(.filterQueryChanged(query: searchController.searchBar.text))
    }
}

extension LifestyleViewController: CalendarBarDelegate {
    func didSelectWeek(with week: CalendarBar.Week, selected date: Date?) {
        guard let date = date else { return }

        calendarAnimator?.closeBar()
        viewStore.send(.onSelectedWeek(.init(week, date)))

        // Reload header info
        var snapshot = dataSource.snapshot()
        if viewStore.disposableItems.map(\.section).contains(.ongoing) {
            snapshot.reloadSections([.ongoing])
            dataSource.apply(snapshot)
        }
    }
}

extension LifestyleViewController {
    private enum Constants {
        // MARK: Sizing constants

        static let estimatedHeaderHeight: CGFloat = 54
        static let estimatedGroupHeight: CGFloat = 186
        static let sectionInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 24, trailing: 20)
        static let interItemSpacing: CGFloat = 18

        /// Top inset for the collection view `calendarBounds.min + 10`
        static let contentTopInset: CGFloat = 55

        /// Top inset for the calendar bar
        static var calendarContainerCornerRadius: CGFloat = 20
        static let calendarInset: CGFloat = -235
        static let calendarHeight: CGFloat = 280
        static let titleInsets: UIEdgeInsets = .create(left: 18)
    }
}
