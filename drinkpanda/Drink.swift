//
//  Drink.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import Foundation
import UIKit

class Drink {
    var name: String
    var storeName: String
    var score: Int
    var review: String
    var date: Date?
    var image: UIImage?

    init(
        name: String,
        storeName: String,
        score: Int,
        review: String,
        date: Date? = nil,
        image: UIImage? = nil
    ) {
        self.name = name
        self.storeName = storeName
        self.score = score
        self.date = date
        self.review = review
        self.image = image
    }
}
