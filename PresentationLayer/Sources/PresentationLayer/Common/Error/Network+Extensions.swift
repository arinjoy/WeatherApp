//
//  File.swift
//  
//
//  Created by Arinjoy Biswas on 14/7/2024.
//

import Foundation
import DataLayer

extension NetworkError {

    // NOTE: Map more custom error messages if needed
    /// such `serviceUnavailable`, `forbidden` etc.
    /// based on the use cases and granularity of messaging required.
    ///
    var title: String {
        switch self {
        case .notFound:
            return "City not found!";
        case .networkFailure:
            return "You seem to be offline!";
        default:
            return "Something went wrong!"
        }
    }

    var message: String {
        switch self {
        case .notFound:
            return "Please adjust keyword or postcode."
        case .networkFailure:
            return "Please connect to the Internet and start punting.";
        default:
            return "Please try again later.";
        }
    }

    var iconName: String {
        switch self {
        case .notFound:
            return "cloud"
        case .networkFailure:
            return "wifi.exclamationmark"
        default:
            return "exclamationmark.icloud"
        }
    }
}
