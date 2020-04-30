//
//  CalendarBar.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-29.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class CalendarBar: UIView {
    
    enum Section: Int {
        case calendar
    }
    
    // Constraints
    
    private let cornerRadius: CGFloat = 20
    private let initialHeight: CGFloat = 248 // 35
    
    private let indicatorHeight: CGFloat = 5
    private let indicatorWidth: CGFloat = 48
    private let indicatorInsets: UIEdgeInsets = .create(bottom: 8)
    
    private let titleInsets: UIEdgeInsets = .create(left: 18)
    
    private let daysGroupHeight: CGFloat = 32
    private let calendarHeight: CGFloat = 160
    private let calendarInsets: UIEdgeInsets = .create(right: 8, bottom: 26, left: 12)
    
    // -- Constraints --
    
    private var heightConstraint: NSLayoutConstraint! = nil
    private let titleLabel: UILabel = UILabel.create(fontStyle: .headline, textColor: .white)
    
    fileprivate var collectionView: UICollectionView! = nil
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        
        backgroundColor = UIColor(collection: .olive)
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: initialHeight)
        heightConstraint.isActive = true
        
        // -- Disclosure indicator --
        
        let disclosureIndicator = UIView()
        disclosureIndicator.backgroundColor = .white
        disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicator.layer.cornerRadius = indicatorHeight / 2
        
        addSubview(disclosureIndicator)
        NSLayoutConstraint.center(disclosureIndicator, in: self, for: [.horizontal])
        NSLayoutConstraint.snap(disclosureIndicator, to: self, for: [.bottom], sizeAttributes: [.height(value: indicatorHeight), .width(value: indicatorWidth)], with: indicatorInsets)
        
        // -- Title label --
        
        titleLabel.text = "March 2020"
        addSubview(titleLabel)
        NSLayoutConstraint.snap(titleLabel, to: self, for: [.left, .top], with: titleInsets)
        
        // -- Calendar --
        
        configureHierarchy()
        configureDataSource()
    }
}

extension CalendarBar {
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let self = self else { return nil }
            
            // --- Item ---
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // --- Group ---
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(self.daysGroupHeight) )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
            
            // --- Section ---
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
}

extension CalendarBar {
    
    func configureHierarchy() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CalendarItemCell.self)
        collectionView.backgroundColor = UIColor(collection: .olive)
        
        addSubview(collectionView)
        NSLayoutConstraint.snap(collectionView, to: self, for: [.left, .right, .bottom], sizeAttributes: [.height(value: calendarHeight)], with: calendarInsets)
    }
    
    func configureDataSource() {
        
        let calendar = Calendar.current
        guard let days = calendar.range(of: .day, in: .month, for: Date())?.count else { return }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, index: Int) -> UICollectionViewCell? in
            
            let cell: CalendarItemCell = collectionView.dequeueReusableCell(for: indexPath)
            
            let isCurrentMonth = index <= days
            let day = isCurrentMonth ? index : index - days
            cell.configure(day: day, isCurrentMonth: isCurrentMonth)
            return cell
        }
        
        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.calendar])
        snapshot.appendItems(Array(0..<35)) // -- one month of days + remaining items
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
