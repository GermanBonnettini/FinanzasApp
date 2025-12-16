//
//  Item.swift
//  FinanzasApp
//
//  Created by H4MM3R-9 on 16/12/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
