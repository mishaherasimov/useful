import Foundation

extension Array {
    public func appending(_ value: Element, condition: Bool) -> Self {
        var args = self
        if condition {
            args.append(value)
        }
        return args
    }

    public func appending(_ values: [Element]) -> Self {
        var args = self
        args.append(contentsOf: values)
        return args
    }
}
