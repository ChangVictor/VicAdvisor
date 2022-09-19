//
//  UIImage+Extension.swift
//  VicAdvisor
//
//  Created by Victor Chang on 18/09/2022.
//

import Foundation
import UIKit

extension UIImage {
	static func from(data: Data?) -> UIImage? {
		if let data = data {
			return UIImage(data: data)
		}
		return UIImage(systemName: "picture")
	}
}
