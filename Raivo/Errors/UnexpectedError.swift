//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

import Foundation

/// Error that describes catastrophic failures that should *NOT* trigger.
///
/// - vitalFunctionalityIsStub: A vital method was executed, but it turned out to be a stub method
/// - noErrorButNotSuccessful: Code did not run successful, but there was no error (this should not trigger)
public enum UnexpectedError: LocalizedError {
    
    case vitalFunctionalityIsStub
    case noErrorButNotSuccessful(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .vitalFunctionalityIsStub:
            log.error("Exception occurred")
            return "A vital method was executed, but it turned out to be a stub method"
        case .noErrorButNotSuccessful(let message):
            log.error("Exception occurred")
            log.error(message)
            return message
        }
    }
    
}
