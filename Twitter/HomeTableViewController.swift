//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Laura Baker on 9/28/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
        
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
    }
    
    @objc func loadTweets(){
        
        numberOfTweets = 20
        
        let homeTimelineURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: homeTimelineURL, parameters: myParams, success:
            { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                
                self.tweetArray.append(tweet)
            }
                
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            
        }, failure: {(Error) in
            print("Could not retreive tweet")
        })
        
    }
    
    func loadMoreTweets(){
        
        let homeTimelineURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: homeTimelineURL, parameters: myParams, success:
            { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                
                self.tweetArray.append(tweet)
            }
                
                self.tableView.reloadData()
            
        }, failure: {(Error) in
            print("Could not retreive tweet")
        })
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as! String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as! String
        
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data{
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    

}
