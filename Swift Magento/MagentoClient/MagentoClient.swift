//
//  MagentoClient.swift
//  Swift Magento
//
//  Created by Dmytro on 8/30/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import Foundation

class MagentoClient {
    static let shared = MagentoClient()
    let sharedWebClient = WebClient(baseUrl: "https://magento23xdemo.tigren.com/rest/V1")

    private init() {}

    func getCurrency(completion: @escaping (Result<MageCurrency, CustomError>) -> ()) -> URLSessionDataTask? {
        let restResource = Resource<MageCurrency, CustomError>(jsonDecoder: JSONDecoder(), path: "/directory/currency")
        return sharedWebClient.load(resource: restResource, completion: completion)
    }
}
