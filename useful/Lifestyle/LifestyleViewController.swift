//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit
import Lottie

class LifestyleViewController: UIViewController {
    
    // MARK: Sizing constants
    
    private let estimatedHeaderHeight: CGFloat = 54
    private let estimatedGroupHeight: CGFloat = 186
    private let sectionInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 24, trailing: 20)
    private let interItemSpacing: CGFloat = 18
    
    /// Top inset for the collection view `calendarBounds.min + 10`
    private let contentTopInset: CGFloat = 55
    
    /// Top inset for the calendar bar
    private var calendarContainerCornerRadius: CGFloat = 20
    private let calendarInset: CGFloat = -235
    private let calendarHeight: CGFloat = 280
    private let titleInsets: UIEdgeInsets = .create(left: 18)
    
    var presenter: LifestyleViewPresenter!
    var dataSource: UICollectionViewDiffableDataSource<LifeStyleSection, DisposableItem>! = nil
    
    // Collection view and related view
    
    private lazy var eventView: EventView = EventView(contentVerticalInset: contentTopInset)
    private var eventViewConstraints: [NSLayoutConstraint] = []
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(refreshItems(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.contentInset.top = self.contentTopInset
        collectionView.refreshControl = self.refreshControl
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ItemCell.self)
        collectionView.register(SuggestedItemsCell.self)
        collectionView.register(TitleSupplementaryView.self, kind: .header)
        collectionView.backgroundColor = UIColor(collection: .darkGray)
        return collectionView
    }()
    
    
    // -- Collection view and related view --
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
        view.backgroundColor = UIColor(collection: .olive)
        configureHierarchy()
        configureDataSource()
        configureCalendarBar()
        
        presenter.loadItems(isReloading: false)
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
    
    // MARK: View logic
    
    func refreshDisposableItems(animatingDifferences: Bool) {
        
        let content = presenter.disposableItems
        
        guard !content.isEmpty else {
            
            configureBackgroundView(for: .empty)
            dataSource.apply(NSDiffableDataSourceSnapshot<LifeStyleSection, DisposableItem>(), animatingDifferences: animatingDifferences)
            return
        }
        
        collectionView.backgroundView = nil
        var snapshot = NSDiffableDataSourceSnapshot<LifeStyleSection, DisposableItem>()
        content.forEach { (section, items) in
            snapshot.appendSections([section])
            snapshot.appendItems(items)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    @objc private func refreshItems(_ sender: UIRefreshControl) {

        presenter.loadItems(isReloading: true)
    }
}

extension LifestyleViewController {
    
    func configureCalendarBar() {
        
        // -- Container view --
        // Helps to handle collection view oscillation
        
        let containerView = UIView.create(backgroundColor: UIColor(collection: .olive), cornerRadius: calendarContainerCornerRadius)
        view.addSubview(containerView)
        let containerConstraints = NSLayoutConstraint.snap(containerView, to: collectionView, for: [.left, .right, .top])
        if let containerTopConstraint = containerConstraints[.top] {
            calendarContainerTopConstraint = containerTopConstraint
        }
        
        // -- Calendar header --
        
        let titleBackgroundView = UIView.create(backgroundColor: UIColor(collection: .olive))
        let titleLabel: UILabel = UILabel.create(fontStyle: .headline, textColor: .white)
        titleLabel.text = Date().formatted(as: .custom(style: .monthYear, timeZone: .current))
        
        view.insertSubview(titleBackgroundView, aboveSubview: calendarBar)
        NSLayoutConstraint.snap(titleBackgroundView, to: view, for: [.left, .right])
        
        titleBackgroundView.addSubview(titleLabel)
        NSLayoutConstraint.snap(titleLabel, to: titleBackgroundView, for: [.top, .right, .bottom], with: titleInsets)
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: titleInsets.left).activate()
        
        let topHeaderConstraint = titleBackgroundView.topAnchor.constraint(equalTo: collectionView.topAnchor)
        calendarBarHeaderTopConstraint = topHeaderConstraint
        topHeaderConstraint.activate()
        
        // -- Calendar --
        
        containerView.addSubview(calendarBar)
        
        let calendarConstraint = NSLayoutConstraint.snap(calendarBar, to: containerView, for: [.left, .right, .top], sizeAttributes: [.height(value: calendarHeight)], with: .create(top: calendarInset))
        
        // make container view same height as a calendar bar visible portion
        containerView.bottomAnchor.constraint(equalTo: calendarBar.bottomAnchor).activate(with: .defaultLow)
        
        if let calendarTopConstraint = calendarConstraint[.top] {
            calendarAnimator = CalendarAnimator(inset: calendarInset, constraint: calendarTopConstraint, calendar: calendarBar)
        }
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
    
    func configureBackgroundView(for event: EventView.EventType) {
    
        eventView.removeConstraints(eventViewConstraints)
        eventView.configure(for: event)
        collectionView.backgroundView = eventView
        
        let sideConstraint = NSLayoutConstraint.snap(eventView, to: view, for: [.left, .right, .bottom])
        let topConstraint = eventView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        eventViewConstraints = Array(sideConstraint.values) + [topConstraint]
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
            
            let traitCollection = layoutEnvironment.traitCollection
            
            var columns = 0
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.compact, .compact), (.regular, _):
                columns = 4
            default:
                columns = 2
            }
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(self.estimatedGroupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
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
        
        dataSource = UICollectionViewDiffableDataSource<LifeStyleSection, DisposableItem>(collectionView: collectionView) {  [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, disposableItem: DisposableItem) -> UICollectionViewCell? in
            
            guard let self = self else { return nil }
            
            let content = self.presenter.disposableItems[indexPath.section]
            
            // print("The identifider is \(disposableItem) the index path is \(indexPath)")
            
            let isLast = disposableItem == self.presenter.disposableItems[indexPath.section].items.last
            
            // If last item in a first section
            if isLast, content.section == .ongoing {
                
                let cell: SuggestedItemsCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(items: 6)
                return cell
            } else {
                
                let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(name: disposableItem.name, imageURL: disposableItem.imageURL, isCompleted: disposableItem.isCompleted == true)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (
            collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            let header = self.presenter.disposableItems[indexPath.section].section.headerInfo
            let supplementaryView: TitleSupplementaryView = collectionView.dequeueReusableSupplementaryView(for: indexPath, kind: kind)
            supplementaryView.configure(header: header)
            
            return supplementaryView
        }
        
        // Initial data
        refreshDisposableItems(animatingDifferences: false)
    }
}

extension LifestyleViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        calendarAnimator?.closeBar()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Helps to mimic the behaviour of the stretchy navigation bar
        let isNegativeDirection = scrollView.contentOffset.y <= -contentTopInset
        elasticTopInset = isNegativeDirection ? abs(scrollView.contentOffset.y) - contentTopInset : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let underConstruction = UnderConstructionViewController()
        present(underConstruction, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension LifestyleViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.filterDisposableItems(query: searchController.searchBar.text)
    }
}

extension LifestyleViewController: LifestyleView {
    
    func loadingDisposableItems(with info: LoadInfo) {
        
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
            refreshDisposableItems(animatingDifferences: true)
        case .isLoading: break
        }
    }
}
