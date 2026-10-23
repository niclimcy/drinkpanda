//
//  Drink.swift
//  drinkpanda
//
//  Created by Nicholas Lim on 19/10/26.
//

import CoreLocation
import Foundation
import UIKit

struct Drink: Identifiable {
    let id: UUID
    
    var name: String
    var storeName: String
    var score: Int
    var review: String
    var date: Date?
    var image: UIImage?
    var coordinate: CLLocationCoordinate2D?
    
    init(
        id: UUID = UUID(),
        name: String,
        storeName: String,
        score: Int,
        review: String,
        date: Date? = nil,
        image: UIImage? = nil,
        coordinate: CLLocationCoordinate2D? = nil
    ) {
        self.id = id
        self.name = name
        self.storeName = storeName
        self.score = score
        self.review = review
        self.date = date
        self.image = image
        self.coordinate = coordinate
    }
}


extension Drink: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, storeName, score, review, date, latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        storeName = try container.decode(String.self, forKey: .storeName)
        score = try container.decode(Int.self, forKey: .score)
        review = try container.decode(String.self, forKey: .review)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        image = nil
        
        if let lat = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let lon = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            coordinate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(storeName, forKey: .storeName)
        try container.encode(score, forKey: .score)
        try container.encode(review, forKey: .review)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(coordinate?.latitude, forKey: .latitude)
        try container.encodeIfPresent(coordinate?.longitude, forKey: .longitude)
    }
}
