//
//  Created by Arinjoy Biswas on 17/6/2023.
//

import Foundation

public final class Scheduler {

    public static var background: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()

    public static let main = RunLoop.main
}
