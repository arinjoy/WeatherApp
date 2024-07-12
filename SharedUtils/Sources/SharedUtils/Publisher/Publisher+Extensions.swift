//
//  Created by Arinjoy Biswas on 17/6/2023.
//

import Foundation
import Combine

public extension Publisher {

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        // By definition `Just` should never fail, but some syntax sugar has been
        // added to make it usable conveniently to avoid an Apple's warning
        return Just(output)
            .setFailureType(to: Failure.self)
            .catch { _ in AnyPublisher<Output, Failure>.empty() }
            .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        // By definition `Just` should never fail, but some syntax sugar has been
        // added to make it usable conveniently to avoid an Apple's warning
        return Fail(error: error).eraseToAnyPublisher()
    }
}

public extension Publisher {

    /**
     The flatMapLatest operator behaves much like the standard `flatMap` operator, except that whenever
     a new item is emitted by the source Publisher, it will unsubscribe to and stop mirroring the Publisher
     that was generated from the previously-emitted item, and begin only mirroring the current one.
     */
    func flatMapLatest<T: Publisher>(
        _ transform: @escaping (Self.Output) -> T
    ) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
}
