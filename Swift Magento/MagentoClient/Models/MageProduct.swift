//
//  DirectoryCurrency.swift
//  Swift Magento
//
//  Created by Dmytro on 8/29/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import Foundation

struct MageProduct: Decodable {
    var id: Int
    var sku: String
    var name: String
    var price: Float
    var custom_attributes: [MageCustomAttribute]
}

struct MageProducts: Decodable {
    var items: [MageProduct]
}

enum DecodableValue: Decodable {
    
    case int(Int), string(String)
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        throw QuantumError.missingValue
    }
    enum QuantumError:Error {
        case missingValue
    }
}


struct MageCustomAttribute: Decodable {
    var attributeCode: String
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case attributeCode = "attribute_code"
        case value
    }
}

extension MageCustomAttribute {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        attributeCode = try container.decode(String.self, forKey: .attributeCode)
        value = try? container.decode(String.self, forKey: .value)
    }
}

