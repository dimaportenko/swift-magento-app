//
//  DirectoryCurrency.swift
//  Swift Magento
//
//  Created by Dmytro on 8/29/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import Foundation

struct MageCurrency: Decodable {
    var base_currency_code: String
    var base_currency_symbol: String
    var default_display_currency_code: String
    var default_display_currency_symbol: String
}
