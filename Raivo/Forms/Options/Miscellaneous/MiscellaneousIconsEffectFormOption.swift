//
//  MiscellaneousIconsEffectFormOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 11/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class MiscellaneousIconsEffectFormOption: BaseFormOption {
    
    static let OPTION_ORIGINAL = MiscellaneousIconsEffectFormOption("original", description: "Original", help: "You can apply effects on icons in the 'misc' screen.")
    static let OPTION_GRAYSCALE = MiscellaneousIconsEffectFormOption("grayscale", description: "Grayscale", help: "You have enabled the grayscale filter for icons.")
//    static let OPTION_RED_TINT = MiscellaneousIconsEffectFormOption("redtint", description: "Red tint", help: "You have enabled the red tint filter for icons.")
    
    static let OPTION_DEFAULT = OPTION_ORIGINAL
    
    static let options = [
        OPTION_ORIGINAL,
        OPTION_GRAYSCALE
//        OPTION_RED_TINT
    ]
    
    var value: String
    var description: String
    var help: String
    
    init(_ value: String, description: String, help: String) {
        self.value = value
        self.description = description
        self.help = help
    }
    
    static func build(_ value: String) -> MiscellaneousIconsEffectFormOption? {
        for option in options {
            if option.value == value {
                return option
            }
        }
        
        return nil
    }
    
    static func == (lhs: MiscellaneousIconsEffectFormOption, rhs: MiscellaneousIconsEffectFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}