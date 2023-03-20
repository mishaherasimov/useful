//
//  CalendarBar.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

protocol CalendarBarDelegate: AnyObject {
    func didSelectWeek(with week: CalendarWeek, selected date: Date?)
}

final class CalendarBar: UIView {
    // -- Constants --

    private lazy var calendarInfo: (days: [Int], currentMonth: Range<Int>)? = calculateCalendar()

    weak var delegate: CalendarBarDelegate?

    // Views

    private lazy var collectionView: UICollectionView = mutate(UICollectionView(frame: .zero, collectionViewLayout: createLayout())) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(CalendarItemCell.self)
        $0.backgroundColor = .clear
    }

    // -- Views --

    private var dataSource: CalendarDataSource! = nil

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Calculate index of the week with the current date
        if
            let info = calendarInfo,
            let day = Calendar.gregorian.dateComponents([.day], from: Date()).day,
            let index = Array(info.days[info.currentMonth]).firstIndex(of: day),
            let week = Week(rawValue: Int(floor(Double((index + info.currentMonth.lowerBound) / 7)))) {
            selectedWeek = week
        }

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
        configureDataSource()

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

    func configureDataSource() {
        let calendar = calendarInfo

        dataSource = CalendarDataSource(collectionView: collectionView) {
            let index = $2
            return mutate($0.dequeueReusableCell(for: $1) as CalendarItemCell) { cell in
                guard let (days, currentMonth) = calendar else { return }
                cell.configure(
                    day: days[index],
                    isCurrentMonth: currentMonth.contains(index)
                )
            }
        }

        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<Week, Int>()

        let cells = Array(0..<Constants.numberOfCells).chunked(into: 7) // -- one month of days + remaining items
        CalendarWeek.allCases.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(cells[$0.rawValue])
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

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
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
