//
//  mutate.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-02-16.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

@discardableResult
func mutate<T>(_ value: T, _ modifier: (T) -> Void) -> T {
    modifier(value)
    return value
}

@discardableResult
func mutate<T>(_ value: inout T, _ modifier: (inout T) -> Void) -> T {
    modifier(&value)
    return value
}
