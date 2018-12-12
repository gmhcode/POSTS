//
//  PostController.swift
//  Post
//
//  Created by Greg Hughes on 12/10/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import Foundation

class PostController: Codable {
    
    static let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    static var posts : [Post] = []
    
    
    static func fetchPosts(reset: Bool = true, completion: @escaping () -> Void){
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        guard let unwrappedURL = baseURL else {completion() ; return}
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        print(queryItems)
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {completion() ; return}
        
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        
        //request
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        print(request)
        
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if error != nil {
                completion()
                return
            }
            guard let data = data else {completion() ; return}
            
            let json = JSONDecoder()
            
            
            do{
                
                let postsDictionary = try json.decode([String:Post].self, from: data)
                
                var posts = postsDictionary.compactMap({($0.value)})
                posts.sort(by: {($0.timestamp > $1.timestamp)})
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
                
            } catch {
                print("There was an error in \(#function) \(error) : \(error.localizedDescription)")
                completion()
            }
        }
        dataTask.resume()
    }
    
    
//    if posts.last.text = 
    
    static func addNewPostWith(username: String, text: String, completion: @escaping () -> Void){
        let newPost = Post(text: text, username: username)
        
        var postData : Data
        
        do{
            let jsonEncoder = JSONEncoder()
            let encodedPostData = try jsonEncoder.encode(newPost)
            postData = encodedPostData
        }catch{
            print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription)")
            completion()
            return
        }
        
        guard let url = baseURL else {completion() ; return}
        let postEndPoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndPoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            
            if let error = error {
                print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data, let dataAsAString = String(data: data, encoding: .utf8) else {completion() ; return}
            
            print(dataAsAString)
            
            
            fetchPosts() {
                completion()
            }
            }.resume()
        
    }
    
    
}
