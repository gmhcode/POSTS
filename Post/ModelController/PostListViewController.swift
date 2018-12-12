//
//  PostListViewController.swift
//  Post
//
//  Created by Greg Hughes on 12/10/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    
    let postController = PostController()
    var refreshControl: UIRefreshControl!

    
    @IBOutlet weak var postTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postTableView.addSubview(refreshControl)
        
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
       
        
        PostController.fetchPosts {
            self.reloadTableView()
        }
    }
   
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PostController.posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        cell.textLabel?.text = PostController.posts[indexPath.row].text
        
        cell.detailTextLabel?.text = PostController.posts[indexPath.row].username + "\(PostController.posts[indexPath.row].timestamp)"
        
        return cell
    }
    
    
    
    @IBAction func addButtonAction(_ sender: Any) {
        presentNewPostAlert()
        
        
    }
    
    
    
    func presentNewPostAlert(){
        
        let alertController = UIAlertController(title: "Add Post", message: nil, preferredStyle: .alert)
        
        
        var usernameTextField = UITextField()
        
        alertController.addTextField { (usernameTF) in
            usernameTextField.placeholder = "Enter your username"
            usernameTextField = usernameTF
        }
        
        var messageTextField = UITextField()
        
        alertController.addTextField { (messageTF) in
            messageTextField.placeholder = "Enter your message"
            messageTextField = messageTF
        }
        
        
        
        
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            
           if usernameTextField.text != "",  messageTextField.text != "",
                let username = usernameTextField.text, let text = messageTextField.text {
                
                PostController.addNewPostWith(username: username, text: text, completion: {
                    self.reloadTableView()
                    
                })
                
            }else {
                self.presentErrorAlert()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        alertController.addAction(postAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    
    func presentErrorAlert(){
        let alertController = UIAlertController(title: "Error", message: "the text fields are missing information, try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        
    }
    
    
    
    func reloadTableView(){
        
        DispatchQueue.main.async {
            
            self.postTableView.reloadData()
            
        }
    }
    
    @objc func refreshControlPulled(){
        PostController.fetchPosts {
            
            
            DispatchQueue.main.async {
                
                self.refreshControl.endRefreshing()
                
            }
            
        }
    }
    
    
    
    
    
    
    
    
}

extension PostListViewController{
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       
        
        if indexPath.row >= (PostController.posts.count - 1){
           
            let preFetchCount = PostController.posts.count
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            PostController.fetchPosts(reset: false) {
                
            let postFetchCount = PostController.posts.count
                
                if preFetchCount == postFetchCount{
                    
                    print("❇️\(preFetchCount)")
                    print("🚳\(postFetchCount)")
                    
                }
                else {
                    
                    PostController.fetchPosts(reset: false) {
                        self.reloadTableView()
                        
                        print("❇️\(preFetchCount)")
                        print("🚳\(postFetchCount)")
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
}
