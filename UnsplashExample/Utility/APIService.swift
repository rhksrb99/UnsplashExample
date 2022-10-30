//
//  APIService.swift
//  UnsplashExample
//
//  Created by 박관규 on 2022/10/29.
//

import Foundation

import Alamofire

class APIService {
    
    static func searchPhoto(query: String, completion: @escaping (SearchPhoto?, Int?, Error?) -> Void) {
        
        let url = "\(APIKey.photoURL)\(query)"
        let header: HTTPHeaders = ["Authorization": APIKey.authorization]
        
        AF.request(url, method: .get, headers: header).validate().responseDecodable(of: SearchPhoto.self) { response in
            
            let statusCode = response.response?.statusCode
            
            switch response.result {
            case .success(let value):
                
                completion(value, statusCode, nil)
                
            case .failure(let error):
                
                completion(nil, statusCode, error)
                
            }
        }
    }
    
    private init() { }
    
}
