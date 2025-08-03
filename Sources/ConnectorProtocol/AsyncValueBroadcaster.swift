//
//  AsyncValueBroadcaster.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 02/08/2025.
//

import Foundation

public actor AsyncValueBroadcaster<T: Sendable> {
    private var latestValue: T?
    private var continuations: [UUID: AsyncStream<T>.Continuation] = [:]

    public init() {}
    
    /// Broadcasts a new value to all current subscribers.
    public func send(_ value: T) {
        latestValue = value

        let currentContinuations = continuations.values
        Task {
            for continuation in currentContinuations {
                continuation.yield(value)
            }
        }
    }

    /// Subscribes to the broadcaster. Returns an AsyncStream and the subscription ID.
    public func subscribe() -> (stream: AsyncStream<T>, id: UUID) {
        let id = UUID()

        let stream = AsyncStream<T> { continuation in
            continuations[id] = continuation

            if let value = latestValue {
                Task {
                    continuation.yield(value)
                }
            }

            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.removeSubscriber(id)
                }
            }
        }

        return (stream, id)
    }

    /// Manually unsubscribe using the UUID returned from `subscribe()`.
    public func unsubscribe(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }

    /// Manually unsubscribe using the UUID returned from `subscribe()`.
    public func unsubscribeAll() {
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }

    /// Called internally on stream termination.
    private func removeSubscriber(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
