//
//  APIservice.swift
//  Task
//
//  Created by Admin on 9/19/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit

class APIService: NSObject {
    var dataArray = [[String: AnyObject]]()
    var query = ""
    lazy var endPoint: String = {
        return "https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=\(self.query)&gpslimit=10"
    }()
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        let urlString = endPoint
        dataArray.removeAll()
        
        guard let url = URL(string: urlString) else { return completion(.Error("Invalid URL, we can't find your item")) }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do{
                let person = try JSONDecoder().decode(ItemModel.self, from: data)
                guard let pageArray = person.query?.pages else{return}
                print(pageArray.count)
                if pageArray.count > 0{
                    for page in pageArray{
                        
                        let dic = ["pageid": page.pageid ?? 0,"title": page.title ?? "","imageUrl": page.thumbnail?.source ?? "","width": page.thumbnail?.width ?? 0,"height": page.thumbnail?.height ?? 0,"description": page.terms?.description ?? ""] as [String : Any]
                        
                        self.dataArray.append(dic as [String : AnyObject])
                        
                    }
                    print(self.dataArray)
                    if self.dataArray.count > 0{
                        DispatchQueue.main.async {
                            completion(.Success(self.dataArray))
                        }
                    }else{
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
                    }
                }
                
            }catch let jsonError{
                print("Error serializing json:", jsonError)
            }
        }
        task.resume()
    }
}

enum Result<T> {
    case Success(T)
    case Error(String)
}





