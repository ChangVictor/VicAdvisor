//
//  MainPresenter.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import Foundation

protocol MainViewPresenterProtocol: AnyObject {
	var delegate: MainViewProtocol? { get set }
	var restaurants: [Restaurant] { get }
	
	func getRestaurants()
	func cleanRestaurants()
	func getCachedImage(url: String) -> Data?
	func canDownload() -> Bool
	func getImage(
		from url: String,
		onSuccess: @escaping (Data) -> (Void),
		onError: @escaping (Error) -> (Void)
	) -> UUID?
	func cancelLoad(id: UUID)
}

class MainViewPresenter: MainViewPresenterProtocol {
	
	weak var delegate: MainViewProtocol?
	
	var restaurants = [Restaurant]()
	private var restClient: VicAdvisorApiClientProtocol
	private var isDownloading = false
	
	init(restClient: VicAdvisorApiClientProtocol = VicAdvisorApiClient()) {
		self.restClient = restClient
	}
	
	func getRestaurants() {
		self.restClient.getRestaurants { [weak self] result in
			guard let strongSelf = self else { return }
			strongSelf.isDownloading = false
			strongSelf.restaurants.append(contentsOf: result.data)
			strongSelf.delegate?.onSuccess()
			
		} onError: { [weak self] _ in
			guard let strongSelf = self else { return }
			strongSelf.isDownloading = true
			strongSelf.delegate?.onError()
			return
		}
		
	}
	
	func cancelLoad(id: UUID) {
		self.restClient.cancelLoad(id: id)
	}
	
	func canDownload() -> Bool {
		return !self.isDownloading
	}
	
	func cleanRestaurants() {
		self.restaurants = []
	}
	
	func getCachedImage(url: String) -> Data? {
		return self.restClient.getCachedImage(url: url)
	}
	
	func getImage(
		from url: String,
		onSuccess: @escaping (Data) -> (Void),
		onError: @escaping (Error) -> (Void)
	) -> UUID? {
		return self.restClient.getImage(
			from: url,
			onSuccess: { data in
				onSuccess(data)
			}, onError: { error in
				onError(error)
			}
		)
	}
}
