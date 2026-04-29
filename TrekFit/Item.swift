//
//  Item.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 29/04/26.
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
