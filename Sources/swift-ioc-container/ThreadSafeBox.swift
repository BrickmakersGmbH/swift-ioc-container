//
//  ThreadSafeBox.swift
//  
//
//  Created by Frank Schaust on 08/02/2020.
//

import Foundation

class ThreadSafeBox<T> {
    private var _value: T?
    private var constructor: () -> T
    private var queue: DispatchQueue = DispatchQueue(label: "ThreadSafe.Serial.Queue")
    
    init(_ constructor: @escaping () -> T) {
        self.constructor = constructor
    }
    
    public func read() -> T {
        let value: T? = queue.sync {
            return self._value
        }
        guard let val = value else {
            self.write()
            return read()
        }
        return val
    }
    
    private func write() {
        queue.sync(flags: .barrier) {
            self._value = self.constructor()
        }
    }
    
}
