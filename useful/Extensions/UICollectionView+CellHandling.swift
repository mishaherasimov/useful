//
//  UICollectionView+CellHandling.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

public enum SupplementaryViewKind: String {
    case header, footer
    
    func kindIdentifier<T: UICollectionReusableView>(_: T.Type) -> String {
        return T.defaultReuseIdentifier + self.rawValue
    }
}

extension UICollectionView {
    
    public func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    public func register<T: UICollectionReusableView>(_: T.Type, kind: SupplementaryViewKind) {
        register(T.self, forSupplementaryViewOfKind: T.defaultReuseIdentifier + kind.rawValue, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }
    
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(for indexPath: IndexPath, kind: String) -> T {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue reusabe view with identifier: \(T.defaultReuseIdentifier) of kind: \(kind)")
        }

        return supplementaryView
    }
}
