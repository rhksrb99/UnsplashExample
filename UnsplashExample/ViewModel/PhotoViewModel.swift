//
//  PhotoViewModel.swift
//  UnsplashExample
//
//  Created by 박관규 on 2022/10/29.
//

import Foundation

import RxSwift
import RxCocoa

enum SearchError: Error {
    case noPhoto
    case serverError
}

class PhotoViewModel {
    
    var photoList = PublishSubject<SearchPhoto>()
    
    func requestSearchPhoto(query: String) {
        APIService.searchPhoto(query: query) { photo, statusCode, error in
            
            guard let statusCode = statusCode else {
                self.photoList.onError(SearchError.serverError)
                return
            }
            
            guard let photo = photo else {
                self.photoList.onError(SearchError.noPhoto)
                return
            }
            
            self.photoList.onNext(photo)
        }
    }
    
}
