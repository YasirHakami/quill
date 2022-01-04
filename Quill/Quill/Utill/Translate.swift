//
//  translet.swift
//  Quill
//
//  Created by Yasir Hakami on 04/01/2022.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizble", bundle: .main, value: self, comment: self)
    }
}
