//
//  MainViewController.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import UIKit

protocol MainViewProtocol: AnyObject {
	func onSuccess()
	func onError()
}

class MainViewController: UITableViewController, MainViewProtocol {
	private var presenter: MainViewPresenterProtocol
	
	init(_ presenter: MainViewPresenterProtocol = MainViewPresenter()) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
		self.presenter.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("required init coder")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.title = "VicAdvisor"
		
		self.registerCell()
		self.presenter.getRestaurants()
	}
	
	private func registerCell() {
		tableView.register(RestaurantCell.self, forCellReuseIdentifier: RestaurantCell.identifier)
	}
	
	private func image(data: Data?) -> UIImage? {
		if let data = data {
			return UIImage(data: data)
		}
		return UIImage(systemName: "picture")
	}
}

extension MainViewController {
	func onSuccess() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	func onError() {
		let alertController = UIAlertController.init(title: "There was an error with the API call", message: "Do you want to retry?", preferredStyle: .alert)
		
		let action = UIAlertAction.init(title: "Yes", style: .default, handler: { _ in
			self.presenter.getRestaurants()
		})
		
		let actionCancel = UIAlertAction.init(title: "No", style: .cancel)
		alertController.addAction(actionCancel)
		alertController.addAction(action)
		DispatchQueue.main.async {
			self.present(alertController, animated: true)
		}
	}
}

extension MainViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter.restaurants.count
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
}

extension MainViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.identifier, for: indexPath) as? RestaurantCell else {
			return UITableViewCell()
		}
		
		let restaurant = self.presenter.restaurants[indexPath.row]
		cell.restaurant = restaurant
		//		cell.setRestaurantImage(nil)
		
		if let data = self.presenter.getCachedImage(url: restaurant.mainPhoto?.source ?? "picture") {
			cell.setRestaurantImage(UIImage.from(data: data))
		} else {
			cell.setRestaurantImage(nil)
		}
		
		let id = self.presenter.getImage(
			from: restaurant.mainPhoto?.source ?? "picture",
			onSuccess: { data in
				
				let image = UIImage.from(data: data)
				if cell.restaurant?.mainPhoto?.source == restaurant.mainPhoto?.source {
					DispatchQueue.main.async {
						cell.setRestaurantImage(image)
					}
				}
			}, onError: { error in
				DispatchQueue.main.async {
					cell.setRestaurantImage(UIImage(systemName: "picture"))
				}
			}
		)
		cell.onReuse = {
			if let id = id {
				self.presenter.cancelLoad(id: id)
			}
		}
		
		var favoriteRestaurants = UserDefaults.standard.array(forKey: "favoriteRestaurants") as? [String] ?? [String]()
		favoriteRestaurants.contains(restaurant.uuid) == true ? cell.handleFavoriteStatus(isFavorite: true) : cell.handleFavoriteStatus(isFavorite: false)
		
		
		cell.onFavButtonPressed = { [weak self] in
			if favoriteRestaurants.contains(restaurant.uuid) {
				let removeIdx = favoriteRestaurants.lastIndex(where: {$0 == restaurant.uuid})
				favoriteRestaurants.remove(at: removeIdx!)
				cell.handleFavoriteStatus(isFavorite: false)
			} else {
				cell.handleFavoriteStatus(isFavorite: true)
				favoriteRestaurants.append(restaurant.uuid)
			}
			UserDefaults.standard.set(favoriteRestaurants, forKey: "favoriteRestaurants")
			self?.tableView.reloadData()
		}
		return cell
	}
}
