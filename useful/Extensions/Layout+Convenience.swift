//
//  Layout+Convenience.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2020-04-27.
//  Copyright © 2020 Mykhailo Herasimov. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    static let infinite = UIEdgeInsets.create(right: CGFloat.greatestFiniteMagnitude)

    static func create(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    static func create(vertical: CGFloat, horizontal: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

extension NSLayoutConstraint {

    enum Side: CaseIterable, Hashable, Equatable {

        static let top: Side = .top(priority: .defaultHigh)
        static let bottom: Side = .bottom(priority: .defaultHigh)
        static let left: Side = .left(priority: .defaultHigh)
        static let right: Side = .right(priority: .defaultHigh)

        case top(priority: UILayoutPriority)
        case bottom(priority: UILayoutPriority)
        case left(priority: UILayoutPriority)
        case right(priority: UILayoutPriority)

        static let allCases: [Side] = [.top, .bottom, .left, .right]
    }

    enum PriorityAxis {

        static let horizontal: PriorityAxis = .horizontal(priority: .required)
        static let vertical: PriorityAxis = .vertical(priority: .required)

        case horizontal(priority: UILayoutPriority)
        case vertical(priority: UILayoutPriority)

        var constraintAxis: Axis {
            switch self {
            case .horizontal:
                return .horizontal
            case .vertical:
                return .vertical
            }
        }
    }

    @discardableResult
    static func snap(
        _ subview: UIView,
        to view: UIView,
        for sides: [Side] = Side.allCases,
        sizeAttributes: [CGSize.Attributes] = [],
        with inset: UIEdgeInsets = .zero
    ) -> [Side: NSLayoutConstraint] {

        var constraints: [Side: NSLayoutConstraint] = [:]

        for side in sides {
            switch side {
            case .top(let priority):
                constraints[side] = subview.topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top)
                    .activate(with: priority)
            case .bottom(let priority):
                constraints[side] = subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset.bottom)
                    .activate(with: priority)
            case .left(let priority):
                constraints[side] = subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset.left)
                    .activate(with: priority)
            case .right(let priority):
                constraints[side] = subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset.right)
                    .activate(with: priority)
            }
        }

        size(view: subview, attributes: sizeAttributes)
        return constraints
    }

    static func size(view: UIView, attributes: [CGSize.Attributes]) {

        for attribute in attributes {
            switch attribute {
            case .width(let value):
                view.widthAnchor.constraint(equalToConstant: value).isActive = true
            case .height(let value):
                view.heightAnchor.constraint(equalToConstant: value).isActive = true
            }
        }
    }

    static func center(
        _ subview: UIView,
        in view: UIView,
        for axises: [Axis] = [.vertical, .horizontal],
        with offset: CGPoint = .zero
    ) {

        for axis in axises {
            switch axis {
            case .vertical:
                subview.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.y).isActive = true
            case .horizontal:
                subview.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.x).isActive = true
            @unknown default:
                fatalError("Current axis does not exists")
            }
        }
    }

    @discardableResult
    func activate(with priority: UILayoutPriority = .required) -> NSLayoutConstraint {

        self.priority = priority
        isActive = true
        return self
    }
}

extension CGSize {

    enum Attributes {

        case width(value: CGFloat)
        case height(value: CGFloat)
    }
}
