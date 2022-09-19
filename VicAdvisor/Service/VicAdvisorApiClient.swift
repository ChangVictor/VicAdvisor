//
//  VicAdvisorApiClient.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import Foundation

protocol VicAdvisorApiClientProtocol {
	func getRestaurants(
		onSuccess: @escaping (RestaurantResult) -> (Void),
		onError: @escaping (Error) -> (Void)
	)
	
	func getCachedImage(url: String) -> Data?
	func cancelLoad(id: UUID)
	func getImage(
		from url: String,
		onSuccess: @escaping (Data) -> (Void),
		onError: @escaping (Error) -> (Void)
	) -> UUID?
}

class VicAdvisorApiClient: VicAdvisorApiClientProtocol {
	
	private let baseRestClient: BaseRestClient
	private var images: NSCache<NSString, NSData>
	
	init(
		baseRestClient: BaseRestClient = BaseRestClient(),
		imageCache: NSCache<NSString, NSData> = NSCache<NSString, NSData>()
	) {
		self.baseRestClient = baseRestClient
		self.images = imageCache
	}
	
	func getRestaurants(
		onSuccess: @escaping (RestaurantResult) -> (Void),
		onError: @escaping (Error) -> (Void)
	) {
		self.baseRestClient.performRequest(
			path: Constants.Networking.testPath,
			queryParams: nil,
			onSuccess: { (restaurantResults: RestaurantResult) in
				onSuccess(restaurantResults)
				print("successfully fetched \(restaurantResults.data)")
			},
			onError: { error in
				print("error on api client: \(error.localizedDescription)")
				onError(error)
			}
		)
	}
	
	func cancelLoad(id: UUID) {
		self.baseRestClient.cancelLoad(id: id)
	}
	
	func getCachedImage(url: String) -> Data? {
		return images.object(forKey: url as NSString) as Data?
	}
	
	func getImage(
		from url: String,
		onSuccess: @escaping (Data) -> (Void),
		onError: @escaping (Error) -> (Void)
	) -> UUID? {
		if let imageData = self.getCachedImage(url: url) {
			onSuccess(imageData as Data)
			return nil
		}
		
		return self.baseRestClient.download(
			url: url,
			onSuccess: { data in
				self.images.setObject(data as NSData, forKey: url as NSString)
				onSuccess(data)
			},
			onError: { error in
				onError(error)
			}
		)
	}
}
