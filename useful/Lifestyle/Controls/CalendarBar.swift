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

protocol CalendarBarDelegate: AnyObject {
    func didSelectWeek(with week: CalendarWeek, selected date: Date?)
}

final class CalendarBar: UIView {

    private let viewStore: ViewStoreOf<CalendarFeature>
    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: CalendarBarDelegate?

    // Views

    private lazy var collectionView: UICollectionView = mutate(UICollectionView(frame: .zero, collectionViewLayout: createLayout())) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(CalendarItemCell.self)
        $0.backgroundColor = .clear
    }

    // -- Views --

    private lazy var dataSource: CalendarDataSource = CalendarDataSource(collectionView: collectionView) { [weak viewStore] in
        let index = $2
        return mutate($0.dequeueReusableCell(for: $1) as CalendarItemCell) { cell in
            guard let state = viewStore?.state else { return }
            cell.configure(
                day: state.currentMonth.dayDigits[index],
                isCurrentMonth: state.currentMonth.digitsRange.contains(index)
            )
        }
    }

    private (set) var selectedWeek: CalendarWeek = .week1 {
        didSet {
            guard oldValue != selectedWeek else { return }

        }
    }

    private func updateSelected(from old: CalendarWeek, to new: CalendarWeek) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([old, new])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    init(store: StoreOf<CalendarFeature>) {
        self.viewStore = ViewStore(store)
        super.init(frame: .zero)

        configureUI()
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
        reloadContent()

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
}

extension CalendarBar {

    func createLayout() -> UICollectionViewLayout {

        let layout =
            UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

                guard let self, let sectionType = Week(rawValue: sectionIndex) else { return nil }

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

                if sectionType == self.selectedWeek {

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

extension CalendarBar {
    typealias CalendarDataSource = UICollectionViewDiffableDataSource<CalendarWeek, Int>

    func configureHierarchy() {

        collectionView.delegate = self
        addSubview(collectionView)
        NSLayoutConstraint.snap(
            collectionView,
            to: self,
            for: [.left, .right, .bottom],
            sizeAttributes: [.height(value: Constants.calendarHeight)],
            with: Constants.calendarInsets
        )
    }

    func reloadContent() {
        var snapshot = NSDiffableDataSourceSnapshot<CalendarWeek, Int>()

        for (index, weekItems) in viewStore.currentMonth.dayDigitWeeks.enumerated() {
            if let week = CalendarWeek(rawValue: index)  {
                snapshot.appendSections([week])
                snapshot.appendItems(weekItems)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension CalendarBar: UICollectionViewDelegate {

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let valueIndex = (
            7 * indexPath.section + indexPath
                .row
        ) // formula -- number of days in a week * offset in weeks + offset in current weekdays
        guard
            let newSelectedWeek = Week(rawValue: indexPath.section),
            selectedWeek != newSelectedWeek,
            let calendarInfo = calendarInfo,
            calendarInfo.days.indices ~= valueIndex
        else { return }
        selectedWeek = newSelectedWeek

        let day = calendarInfo.days[valueIndex]

        var components = Calendar.gregorian.dateComponents([.day, .month, .year], from: Date())
        components.day = day

        if let month = components.month {

            switch valueIndex {
            case ..<calendarInfo.currentMonth.startIndex:
                components.month = month - 1
            case calendarInfo.currentMonth.endIndex...:
                components.month = month + 1
            default:
                break
            }

            delegate?.didSelectWeek(with: newSelectedWeek, selected: Calendar.gregorian.date(from: components))
        }
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
        static var numberOfCells: Int { 7 * Week.allCases.count }
        static var calendarHeight: CGFloat { daysGroupHeight * CGFloat(Week.allCases.count) }
    }
}
