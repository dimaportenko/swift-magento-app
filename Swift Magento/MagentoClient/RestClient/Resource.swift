//
//  Resource.swift
//  RESTClient
//
//  Created by Alexandr Gaidukov on 20/10/2017.
//  Copyright © 2017 Alexander Gaidukov. All rights reserved.
//

import Foundation

public struct Resource<A, CustomError> {
    let path: Path
    let method: RequestMethod
    var headers: HTTPHeaders
    var params: JSON
    let parse: (Data) -> A?
    let parseError: (Data) -> CustomError?

    init(path: String,
         method: RequestMethod = .get,
         params: JSON = [:],
         headers: HTTPHeaders = [:],
         parse: @escaping (Data) -> A?,
         parseError: @escaping (Data) -> CustomError?) {
        self.path = Path(path)
        self.method = method
        self.params = params
        self.headers = headers
        self.parse = parse
        self.parseError = parseError
    }
}

extension Resource where A: Decodable, CustomError: Decodable {
    init(jsonDecoder: JSONDecoder = JSONDecoder(),
         path: String,
         method: RequestMethod = .get,
         params: JSON = [:],
         headers: HTTPHeaders = [:]) {
        var newHeaders = headers
        newHeaders["Accept"] = "application/json"
        newHeaders["Content-Type"] = "application/json"

        self.path = Path(path)
        self.method = method
        self.params = params
        self.headers = newHeaders
        
        
        /**
         *  self.parse extended for debuging purpose
         *  release should be
         *  self.parse = {
         *     try? jsonDecoder.decode(A.self, from: $0)
         *  }
         */
        self.parse = { data in
            do {
                print("### data", String(decoding: data, as: UTF8.self))
                let result = try jsonDecoder.decode(A.self, from: data)
                return result
            } catch {
                print("### Resource decode error \(error)")
            }
            return nil
        }
        self.parseError = {
            try? jsonDecoder.decode(CustomError.self, from: $0)
        }
    }
}
