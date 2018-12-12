//
//  PostListViewController.swift
//  Post
//
//  Created by Greg Hughes on 12/10/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    
    
    @objc func refreshControlPulled(){
        PostController.fetchPosts {
            
            
            DispatchQueue.main.async {
                
                self.refreshControl.endRefreshing()
                
            }
            
        }
    }
    //purpose of this function is to refresh the data
    
    
    
    func reloadTableView(){
        
        DispatchQueue.main.async {
            
            self.postTableView.reloadData()
            
        }
    }
    //purpose of this function is to quickly reload the data
    
    
    
    let postController = PostController()
    // why did i make this^^
    var refreshControl: UIRefreshControl!

    
    @IBOutlet weak var postTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadTableView()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postTableView.addSubview(refreshControl)
        
        
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
        // why dont these work??
        
        PostController.fetchPosts {
            self.reloadTableView()
        } // Do any additional setup after loading the view.
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
        
        
        
        //Create the alert controller
        //                let alertController = UIAlertController(title: "🐉🐉🐉🐉🔥🔥🔥🔥", message: "Enter Quote", preferredStyle: .alert)
        //
        //                alertController.addTextField { (textField) in
        //                    textField.placeholder = "Enter your quote"
        //                }
        //
        //                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //
        //                alertController.addAction(cancelAction)
        //
        //                let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
        //
        //                    guard let quoteTextField = alertController.textFields?.first else {return}
        //
        //                    PostController.shared.createQuote(with: quoteTextField.text ?? "")
        //                }
        //                alertController.addAction(addAction)
        //
        //                present(alertController, animated: true)
        //            }
        
        
        
        
        
    }
    func presentErrorAlert(){
        let alertController = UIAlertController(title: "Error", message: "the text fields are missing information, try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        
    }
    
    
    //reload Rows
   
    
   
    
    
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
