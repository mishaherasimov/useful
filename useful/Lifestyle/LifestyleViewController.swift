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

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension LifestyleViewController {
    
    func configureHierarchy() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ItemCell.self)
        collectionView.backgroundColor = UIColor(collection: .darkGray)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.snap(collectionView, to: view)
    }
    
    func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

            let cell: ItemCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(name: "Plastic bottle", image: UIImage(named: "bottle"))
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<3))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

