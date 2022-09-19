//
//  RestaurantResult.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import Foundation

struct RestaurantResult: Codable {
	let data: [Restaurant]
}

struct Restaurant: Codable {
	let name: String
	let uuid: String
	let servesCuisine: String
	let priceRange: Int
	let address: Address
	let aggregateRatings: AggregateRatings
	let bestOffer: BestOffer
	let mainPhoto: MainPhoto?
}

struct Address: Codable {
	let street: String
	let locality: String
	let country: String
}

struct BestOffer: Codable {
	let name: String
	let label: String
}

struct AggregateRatings: Codable {
	let tripadvisor: TripAdvisor
}

struct TripAdvisor: Codable {
	let ratingValue: Double
	let reviewCount: Int
}

struct MainPhoto: Codable {
	let source: String
	let small: String
	
	enum CodingKeys: String, CodingKey {
		case source = "source"
		case small = "184x184"
	}
	
}
