//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class LifestyleViewController: UIViewController {
    
    // MARK: Sizing constants
    
    private let estimatedHeaderHeight: CGFloat = 54
    private let estimatedGroupHeight: CGFloat = 186
    private let sectionInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 24, trailing: 20)
    private let interItemSpacing: CGFloat = 18
    
    /// Top inset for the collection view `calendarBounds.min + 10`
    private let contentTopInset: CGFloat = 55
    
    /// Top inset for the calendar bar
    private var calendarInset: CGFloat = -235
    private let calendarHeight: CGFloat = 280
    private let titleInsets: UIEdgeInsets = .create(left: 18)
    
    enum Section: Int, CaseIterable {
        case ongoing, completed
    }
    
    var presenter: LifestyleViewPresenter!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DisposableItem>! = nil
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.contentInset.top = self.contentTopInset
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ItemCell.self)
        collectionView.register(SuggestedItemsCell.self)
        collectionView.register(TitleSupplementaryView.self, kind: .header)
        collectionView.backgroundColor = UIColor(collection: .darkGray)
        return collectionView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var elasticTopInset: CGFloat = 0 {
        didSet {
            calendarBarTopConstraint?.constant = calendarInset + elasticTopInset
            calendarBarHeaderTopConstraint?.constant = elasticTopInset
        }
    }
    
    private let calendarBar = CalendarBar()
    private var calendarAnimator: CalendarAnimator?
    
    private var calendarBarTopConstraint: NSLayoutConstraint?
    private var calendarBarHeaderTopConstraint: NSLayoutConstraint?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Lifestyle"
        view.backgroundColor = UIColor(collection: .olive)
        configureHierarchy()
        configureDataSource()
        configureCalendarBar()
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
        return .lightContent
    }
}

extension LifestyleViewController {
    
    func configureCalendarBar() {
        
        view.addSubview(calendarBar)
        
        let constraints = NSLayoutConstraint.snap(calendarBar, to: collectionView, for: [.left, .right, .top], sizeAttributes: [.height(value: calendarHeight)], with: .create(top: calendarInset))
        
        if let calendarTopConstraint = constraints[.top] {
            calendarBarTopConstraint = calendarTopConstraint
            calendarAnimator = CalendarAnimator(inset: calendarInset, constraint: calendarTopConstraint, calendar: calendarBar)
            calendarAnimator?.delegate = self
        }
        
        // -- Buffer view --
        // Helps to cover calendar top constraint oscillation
        
        let bufferView = UIView.create(backgroundColor: UIColor(collection: .olive))
        view.insertSubview(bufferView, belowSubview: calendarBar)
        NSLayoutConstraint.snap(bufferView, to: calendarBar, for: [.left, .right])
        bufferView.bottomAnchor.constraint(equalTo: calendarBar.centerYAnchor).activate()
        bufferView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        
        // -- Calendar header --
        
        let titleBackgroundView = UIView.create(backgroundColor: UIColor(collection: .olive))
        let titleLabel: UILabel = UILabel.create(fontStyle: .headline, textColor: .white)
        titleLabel.text = Date().formatted(as: .custom(style: .monthYear, timeZone: .current))

        titleBackgroundView.addSubview(titleLabel)
        NSLayoutConstraint.snap(titleLabel, to: titleBackgroundView, with: titleInsets)
        view.insertSubview(titleBackgroundView, aboveSubview: calendarBar)
        NSLayoutConstraint.snap(titleBackgroundView, to: view, for: [.left, .right])

        let topHeaderConstraint = titleBackgroundView.topAnchor.constraint(equalTo: collectionView.topAnchor)
        calendarBarHeaderTopConstraint = topHeaderConstraint
        topHeaderConstraint.activate()
    }
    
    func configureSearchBar() {
        
        let searchBar = searchController.searchBar
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        searchBar.tintColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search items", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
        
        let searchGlyph = searchBar.searchTextField.leftView as? UIImageView
        searchGlyph?.image = searchGlyph?.image?.withRenderingMode(.alwaysTemplate)
        searchGlyph?.tintColor = .white
        
        if let clearButton = searchBar.searchTextField.value(forKey: "clearButton") as? UIButton {
            
            clearButton.imageView?.tintColor = .white
            
            let configuration = UIImage.SymbolConfiguration(scale: .medium)
            let clearGlyph = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
            
            clearButton.setImage(clearGlyph?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
}

extension LifestyleViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let self = self else { return nil }
            
            // --- Item ---
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // --- Group ---
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(self.estimatedGroupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(self.interItemSpacing)
            
            // --- Section ---
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = self.interItemSpacing
            section.contentInsets = self.sectionInsets
            
            // --- Header ---
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(self.estimatedHeaderHeight))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: SupplementaryViewKind.header.kindIdentifier(TitleSupplementaryView.self), alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        return layout
    }
}

extension LifestyleViewController {
    
    func configureHierarchy() {
        
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.snap(collectionView, to: view, for: [.left, .right, .bottom])
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, DisposableItem>(collectionView: collectionView) {  [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, disposableItem: DisposableItem) -> UICollectionViewCell? in
            
            guard let self = self, let section = Section(rawValue: indexPath.section)  else { return nil }
            
            // print("The identifider is \(disposableItem) the index path is \(indexPath)")
            
            let isLast = disposableItem == self.presenter.disposableItems[indexPath.section].last
            
            // If last item in a first section
            if isLast, section == .ongoing {
                
                let cell: SuggestedItemsCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(items: 6)
                return cell
            } else {
                
                let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(name: disposableItem.title, image: disposableItem.image, isCompleted: section == .completed)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (
            collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            let supplementaryView: TitleSupplementaryView = collectionView.dequeueReusableSupplementaryView(for: indexPath, kind: kind)
            
            if let section = Section(rawValue: indexPath.section) {
                supplementaryView.configure(header: self.presenter.header(for: section))
            }
            
            return supplementaryView
        }
        
        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisposableItem>()
        Section.allCases.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(self.presenter.disposableItems[$0.rawValue])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension LifestyleViewController: CalendarAnimatorDelegate {
    func didUpdateInset(to inset: CGFloat) {
        calendarInset = inset
    }
}

extension LifestyleViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Helps to mimic the behaviour of the stretchy navigation bar
        let isNegativeDirection = scrollView.contentOffset.y <= -contentTopInset
        elasticTopInset = isNegativeDirection ? abs(scrollView.contentOffset.y) - contentTopInset : 0
    }
}

extension LifestyleViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension LifestyleViewController: LifestyleView {}
