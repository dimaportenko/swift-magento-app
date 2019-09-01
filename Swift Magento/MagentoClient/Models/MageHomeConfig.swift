//
//  MageHomeConfig.swift
//  Swift Magento
//
//  Created by Dmytro on 8/30/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import Foundation

struct MageHomeConfig: Decodable {
    var title: String
    var identifier: String
    var content: String
}

struct MageHomeConfigContent: Decodable {
    var slider: [MageHomeConfigSlide]
    var featuredCategories: [String: [String: String]]
}

struct MageHomeConfigSlide: Decodable {
    var title: String
    var image: String
}
