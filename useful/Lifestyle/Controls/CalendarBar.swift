//
//  CalendarBar.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit
import ComposableArchitecture
import Combine

final class CalendarBar: UIView {
    private typealias CalendarDataSource = UICollectionViewDiffableDataSource<CalendarWeek, DayItem>

    private let viewStore: ViewStoreOf<CalendarFeature>
    private var cancellables: Set<AnyCancellable> = []

    // Views

    private lazy var collectionView: UICollectionView = mutate(UICollectionView(frame: .zero, collectionViewLayout: createLayout())) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(CalendarItemCell.self)
        $0.backgroundColor = .clear
    }

    // -- Views --

    private lazy var dataSource: CalendarDataSource = CalendarDataSource(collectionView: collectionView) { [weak viewStore] in
        let item = $2
        return mutate($0.dequeueReusableCell(for: $1) as CalendarItemCell) { cell in
            guard let store = viewStore else { return }
            cell.configure(day: item.day, isCurrentMonth: item.isCurrent)
        }
    }

    init(store: StoreOf<CalendarFeature>) {
        self.viewStore = ViewStore(store)
        super.init(frame: .zero)

        configureUI()
        setupDataSource()
        setupBindings()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundColor = UIColor(collection: .primary)
        layer.cornerRadius = Constants.cornerRadius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        translatesAutoresizingMaskIntoConstraints = false

        // -- Disclosure indicator --

        let disclosureIndicator = mutate(UIView()) {
            $0.backgroundColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = Constants.indicatorHeight / 2
        }

        addSubview(disclosureIndicator)
        NSLayoutConstraint.center(disclosureIndicator, in: self, for: [.horizontal])
        NSLayoutConstraint.snap(
            disclosureIndicator,
            to: self,
            for: [.bottom],
            sizeAttributes: [.height(value: Constants.indicatorHeight), .width(value: Constants.indicatorWidth)],
            with: Constants.indicatorInsets
        )

        // -- Calendar --

        configureHierarchy()

        // -- Legend --

        let stackView = UIStackView.create(axis: .horizontal, spacing: 0, distribution: .fillEqually)
        addSubview(stackView)

        let legends = Calendar.current.veryShortWeekdaySymbols.map {
            UILabel.create(fontStyle: .subheadline, text: $0, textColor: .white, textAlignment: .center)
        }

        stackView.items = legends
        NSLayoutConstraint.snap(stackView, to: collectionView, for: [.left, .right])
        stackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Constants.legendBottomSpacing).isActive = true
    }

    private func configureHierarchy() {
        collectionView.delegate = self
        addSubview(collectionView)
        NSLayoutConstraint.snap(
            collectionView,
            to: self,
            for: [.left, .right, .bottom],
            sizeAttributes: [.height(value: CGFloat(viewStore.totalWeeks) * Constants.daysGroupHeight)],
            with: Constants.calendarInsets
        )
    }

    private func setupBindings() {
        viewStore.publisher
            .selectedWeek
            .removeDuplicates()
            .sink { [unowned dataSource] in
                var snapshot = dataSource.snapshot()
                snapshot.reloadSections([$0])
                dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }

    private func setupDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<CalendarWeek, DayItem>()

        for (index, weekItems) in viewStore.currentMonth.enumerated() {
            if let week = CalendarWeek(rawValue: index)  {
                snapshot.appendSections([week])
                snapshot.appendItems(weekItems, toSection: week)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension CalendarBar: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath),
              let week = CalendarWeek(rawValue: indexPath.section) else {
            return
        }

        viewStore.send(.delegate(.didSelect(.init(week: week, day: day))))
    }
}

extension CalendarBar {
    enum Constants {
        static let cornerRadius: CGFloat = 20

        static let indicatorHeight: CGFloat = 5
        static let indicatorWidth: CGFloat = 48
        static let indicatorInsets: UIEdgeInsets = .create(bottom: 8)

        static let legendBottomSpacing: CGFloat = 10
        static let daysGroupHeight: CGFloat = 32
        static let calendarInsets: UIEdgeInsets = .create(right: 12, bottom: 26, left: 12)
    }
}

extension CalendarBar {
    func createLayout() -> UICollectionViewLayout {
        let layout =
            UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

                guard let self, let sectionType = CalendarWeek(rawValue: sectionIndex) else { return nil }

                // --- Item ---

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // --- Group ---

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(Constants.daysGroupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)

                // --- Section ---

                let section = NSCollectionLayoutSection(group: group)

                // -- Background --

                if sectionType == self.viewStore.selectedWeek {

                    let weekBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
                        elementKind: SupplementaryViewKind.background.kindIdentifier(WeekBackgroundDecorationView.self)
                    )
                    section.decorationItems = [weekBackgroundDecoration]
                }

                return section
            }

        layout.register(
            WeekBackgroundDecorationView.self,
            forDecorationViewOfKind: SupplementaryViewKind.background.kindIdentifier(WeekBackgroundDecorationView.self)
        )

        return layout
    }
}
