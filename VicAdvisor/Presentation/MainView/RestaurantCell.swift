//
//  RestaurantCell.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import UIKit

protocol RestaurantCellProtocol: AnyObject {
	var restaurant: Restaurant? { get set }
	var onFavButtonPressed: (() -> ())? { get set }
	var onReuse: (() -> ()) { get set }
	
	func setRestaurantImage(_ image: UIImage?)
	func handleFavoriteStatus(isFavorite: Bool)
}

class RestaurantCell: UITableViewCell, RestaurantCellProtocol {
	
	static let identifier = "restaurantCell"
	var onFavButtonPressed: (() -> ())?
	var restaurant: Restaurant? {
		didSet {
			self.nameLabel.text = restaurant?.name
			self.rating.text = "Rated \(restaurant?.aggregateRatings.tripadvisor.ratingValue ?? 0) from \(restaurant?.aggregateRatings.tripadvisor.reviewCount ?? 0) reviews"
			self.addressLabel.text = "\(restaurant?.address.street ?? "address no available")\n\(restaurant?.address.locality ?? "city not available"), \(restaurant?.address.country ?? "country not available")"
			self.cuisine.setTitle(restaurant?.servesCuisine, for: .normal)
		}
	}
	
	var onReuse: () -> Void = {}
	
	private let restaurantImage: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFill
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.cornerRadius = 0
		image.clipsToBounds = true
		return image
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 14)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()
	
	let rating: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()
	
	let addressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()
	
	private let cuisine: UIButton = {
		let button = UIButton()
		var config = UIButton.Configuration.tinted()
		config.buttonSize = .small
		config.cornerStyle = .small
		config.background.backgroundColor = UIColor.init(red: 0/255, green: 175/255, blue: 135/255, alpha: 1)
		config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = UIFont.systemFont(ofSize: 10)
			return outgoing
		}
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 5
		button.configuration = config
		button.tintColor = .white
		button.isUserInteractionEnabled = false
		return button
	}()
	
	lazy var favoriteButton: UIButton = {
		lazy var button = UIButton(type: .system)
		button.setImage(UIImage(named: "empty-heart"), for: .normal)
		button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(handleFavoriteTapped), for: .touchUpInside)
		return button
	}()
	
	@objc fileprivate func handleFavoriteTapped(_ sender: UIButton) {
		print("favoriteButton Taped")
		onFavButtonPressed?()
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.clipsToBounds = true
		self.contentView.backgroundColor = .white
		self.contentView.addSubview(restaurantImage)
		self.contentView.addSubview(nameLabel)
		self.contentView.addSubview(rating)
		self.contentView.addSubview(addressLabel)
		self.contentView.addSubview(cuisine)
		self.contentView.addSubview(favoriteButton)
		self.setupLayout()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.preservesSuperviewLayoutMargins = false
		self.separatorInset = UIEdgeInsets.zero
		self.layoutMargins = UIEdgeInsets.zero
	}
	
	private func setupLayout() {
		self.setImageConstraints()
		self.setNameLabelConstraints()
		self.setRatingLabelContraints()
		self.setAddressConstraint()
		self.setupCuisineContraints()
		self.setupFavoriteButtonConstraints()
	}
	
	private func setImageConstraints() {
		self.restaurantImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		self.restaurantImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
		self.restaurantImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
		self.restaurantImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
	}
	
	private func setNameLabelConstraints() {
		self.nameLabel.numberOfLines = 2
		self.nameLabel.leadingAnchor.constraint(equalTo: self.restaurantImage.trailingAnchor, constant: 10).isActive = true
		self.nameLabel.trailingAnchor.constraint(equalTo: self.cuisine.leadingAnchor, constant: -10).isActive = true
		self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
	}
	
	private func setRatingLabelContraints() {
		self.rating.numberOfLines = 2
		self.rating.leadingAnchor.constraint(equalTo: self.restaurantImage.trailingAnchor, constant: 10).isActive = true
		self.rating.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 10).isActive = true
		self.rating.trailingAnchor.constraint(equalTo: self.favoriteButton.leadingAnchor, constant: -10).isActive = true
	}
	
	private func setAddressConstraint() {
		self.addressLabel.numberOfLines = 2
		self.addressLabel.leadingAnchor.constraint(equalTo: self.rating.leadingAnchor).isActive = true
		self.addressLabel.topAnchor.constraint(equalTo: self.rating.bottomAnchor, constant: 8).isActive = true
		self.addressLabel.trailingAnchor.constraint(equalTo: self.favoriteButton.leadingAnchor, constant: -10).isActive = true
		self.addressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
	}
	
	private func setupCuisineContraints() {
		self.cuisine.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
		self.cuisine.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
		self.cuisine.widthAnchor.constraint(equalToConstant: 75).isActive = true
	}
	
	private func setupFavoriteButtonConstraints() {
		self.favoriteButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
		self.favoriteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
		self.favoriteButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	func setRestaurantImage(_ image: UIImage?) {
		self.restaurantImage.image = image
	}
	
	func handleFavoriteStatus(isFavorite: Bool) {
		switch isFavorite {
		case true:
			self.favoriteButton.setImage(#imageLiteral(resourceName: "filled-heart"), for: .normal)
		case false:
			self.favoriteButton.setImage(#imageLiteral(resourceName: "empty-heart"), for: .normal)
		}
	}
}
