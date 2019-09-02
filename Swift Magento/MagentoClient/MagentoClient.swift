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
    
    let homeCmsBlockId = "1"
    let accessToken = "ioqnahqjd2brl3j56nrpkcrnu6thh6s3"
    let sharedWebClient = WebClient(baseUrl: "https://magento23xdemo.tigren.com/rest/V1")

    private init() {}

    func getCurrency(completion: @escaping (Result<MageCurrency, CustomError>) -> ()) -> URLSessionDataTask? {
        let restResource = Resource<MageCurrency, CustomError>(path: "/directory/currency")
        return sharedWebClient.load(resource: restResource, completion: completion)
    }

    func getHomeConfig(completion: @escaping (MageHomeConfigContent?, Error?) -> ()) -> URLSessionDataTask? {
        let restResource = Resource<MageHomeConfig, CustomError>(path: "/cmsBlock/\(homeCmsBlockId)", headers: adminHeader())
        return sharedWebClient.load(resource: restResource) { response in
            if let contentString = response.value?.content {
                do {
                    let result = try JSONDecoder().decode(MageHomeConfigContent.self, from: Data(contentString.utf8))
                    completion(result, nil)
                } catch {
                    print("Error parse content \(error)")
                    completion(nil, error)
                }
            }
        }
    }

    func getConfig(completion: @escaping (Result<[MageStoreConfig], CustomError>) -> ()) -> URLSessionDataTask? {
        let restResource = Resource<[MageStoreConfig], CustomError>(path: "/store/storeConfigs", headers: adminHeader())
        return sharedWebClient.load(resource: restResource, completion: completion)
    }

    func getProducts(categoryId: String, completion: @escaping (Result<MageProducts, CustomError>) -> ()) -> URLSessionDataTask? {
        let params = [
            "searchCriteria[filterGroups][0][filters][0][field]": "category_id",
            "searchCriteria[filterGroups][0][filters][0][value]": categoryId,
            "searchCriteria[filterGroups][0][filters][0][conditionType]": "eq",
            "searchCriteria[filterGroups][1][filters][0][field]": "visibility",
            "searchCriteria[filterGroups][1][filters][0][value]": "4",
            "searchCriteria[filterGroups][1][filters][0][conditionType]": "eq",
            "searchCriteria[pageSize]": "10",
            "searchCriteria[currentPage]": "1",
        ] as JSON
        let restResource = Resource<MageProducts, CustomError>(path: "/products", params: params, headers: adminHeader())
        return sharedWebClient.load(resource: restResource, completion: completion)
    }

    func adminHeader() -> HTTPHeaders {
        return ["Authorization": "Bearer \(accessToken)"]
    }
}
