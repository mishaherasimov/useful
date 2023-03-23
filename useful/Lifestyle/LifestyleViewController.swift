//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import Lottie
import SwiftUI
import Combine
import ComposableArchitecture
import UIKit

typealias LifestyleViewStore = ViewStore<LifestyleViewController.ViewState, LifestyleViewController.ViewAction>

final class LifestyleViewController: UIViewController {
    struct WeekSpan: Equatable {
        let beginning: Date
        let end: Date
    }

    struct ViewState: Equatable {
        let selectedDay: DayItem?
        let weekSpan: WeekSpan?
        let isLoadViewHidden: Bool
        let isRefreshControlHidden: Bool
        let isErrorViewHidden: Bool
        let items: [LifestyleSection]
    }

    enum ViewAction {
        case onViewDidLoad
        case refreshControlTriggered
        case filterQueryChanged(query: String?)
    }

    private let calendarStore: StoreOf<CalendarFeature>
    private var viewStore: LifestyleViewStore
    private var cancellables: Set<AnyCancellable> = []

    init(
        viewStore: LifestyleViewStore,
        calendarStore: StoreOf<CalendarFeature>
    ) {
        self.calendarStore = calendarStore
        self.viewStore = viewStore
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

    private lazy var calendarBar = CalendarBar(store: calendarStore)
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
        viewStore.publisher.items
            .removeDuplicates()
            .sink { [weak self] in
                self?.refresh(sections: $0)
            }
            .store(in: &cancellables)

        viewStore.publisher.isRefreshControlHidden
            .removeDuplicates()
            .sink { [weak self] in
                if $0 {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewStore.publisher.isLoadViewHidden
            .removeDuplicates()
            .sink { [weak self] in
                guard let self else { return }

                if !$0 {
                    LoaderView.shared.start(in: self.view) { [weak self] in
                        guard let self else { return }
                        self.view.insertSubview($0, aboveSubview: self.collectionView)
                    }
                } else {
                    LoaderView.shared.stop()
                }
            }
            .store(in: &cancellables)

        viewStore.publisher.isErrorViewHidden
            .removeDuplicates()
            .sink { [weak self] in
                if !$0 {
                    self?.configureBackgroundView(for: .error)
                }
            }
            .store(in: &cancellables)

        viewStore.publisher.items
            .sink { [weak self] in self?.refresh(sections: $0) }
            .store(in: &cancellables)

        viewStore.publisher.selectedDay
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.calendarAnimator?.closeBar()
                self?.refreshHeader()
            }
            .store(in: &cancellables)
    }

    private func refreshHeader() {
        // Reload header info
        var snapshot = dataSource.snapshot()
        if viewStore.items.map(\.section).contains(.ongoing) {
            snapshot.reloadSections([.ongoing])
            dataSource.apply(snapshot)
        }
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

    @objc
    private func refreshItems(_: UIRefreshControl) {
        viewStore.send(.refreshControlTriggered)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        refresh(sections: viewStore.items, animatingDifferences: false)
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

                let content = self.viewStore.items[indexPath.section]
                let isLast = disposableItem == self.viewStore.items[indexPath.section].items.last

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

            let section = self.viewStore.items[indexPath.section].section
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
        let underConstruction = UIHostingController(rootView: UnderConstructionView())
        underConstruction.view.backgroundColor = .clear

        present(underConstruction, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension LifestyleViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewStore.send(.filterQueryChanged(query: searchController.searchBar.text))
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

extension LifestyleFeature.Action {
    init(action: LifestyleViewController.ViewAction) {
        switch action {
        case .onViewDidLoad:
            self = .onViewDidLoad
        case .refreshControlTriggered:
            self = .refreshControlTriggered
        case .filterQueryChanged(let query):
            self = .filterQueryChanged(query: query)
        }
    }
}

extension LifestyleViewController.ViewState {
    init(state: LifestyleFeature.State) {
        let span = state.currentTimeframe?.weekSpan
        weekSpan = span.map(LifestyleViewController.WeekSpan.init)
        selectedDay = state.currentTimeframe?.day
        isRefreshControlHidden = !state.loadInfo.state.isActive
        isLoadViewHidden = !state.loadInfo.state.isActive || state.loadInfo.type == .fullReload
        isErrorViewHidden = state.loadInfo.state != .failLoading
        items = state.disposableItems
    }
}
