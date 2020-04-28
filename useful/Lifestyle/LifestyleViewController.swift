//
//  LifestyleViewController.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-26.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

class LifestyleViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Lifestyle"
        configureHierarchy()
        configureDataSource()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LifestyleViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(186))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(18)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 24, trailing: 20)
        
        // Header sizing configuration
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(54))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SupplementaryViewKind.header.kindIdentifier(TitleSupplementaryView.self), alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension LifestyleViewController {
    
    func configureHierarchy() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ItemCell.self)
        collectionView.register(SuggestedItemsCell.self)
        collectionView.register(TitleSupplementaryView.self, kind: .header)
        collectionView.backgroundColor = UIColor(collection: .darkGray)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.snap(collectionView, to: view)
    }
    
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            
            // If last item in a section
            if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
                
                let cell: SuggestedItemsCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(items: 6)
                return cell
            } else {
                
                let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(name: "Plastic bottle", image: UIImage(named: "bottle"))
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (
            collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            let supplementaryView: TitleSupplementaryView = collectionView.dequeueReusableSupplementaryView(for: indexPath, kind: kind)
            supplementaryView.configure(title: "Mar 8 - Mar 14", annotation: "Current week")
            return supplementaryView
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<4))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

