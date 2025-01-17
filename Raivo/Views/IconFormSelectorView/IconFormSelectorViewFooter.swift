//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import UIKit

class IconFormSelectorViewFooter: UICollectionReusableView {
    
    @IBAction func addIcon(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo-issuer-icons")!, options: [:])
    }
    
}
