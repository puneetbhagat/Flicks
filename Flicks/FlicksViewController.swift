//
//  FlicksViewController.swift
//  Flicks
//
//  Created by Bhagat, Puneet on 4/2/17.
//  Copyright © 2017 Puneet Bhagat. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    let tmdbApiKey: String = "294d876de63dd7d650e5005a5180b2b7"
    
    var flicks: [NSDictionary] = []
    var tmdbConfig: [NSDictionary] = []
    let tmdbImageBaseUrl: String = "http://image.tmdb.org/t/p/"
    let tmdbPosterSizes: [String] = ["w92",
                                     "w154",
                                     "w185",
                                     "w342",
                                     "w500",
                                     "w780",
                                     "original"]
    
    var searchActive: Bool = false
    var searchedResults: [NSDictionary] = []
    
    @IBOutlet weak var flicksTableView: UITableView!
    @IBOutlet weak var flicksSearchBar: UISearchBar!

    
    @IBOutlet weak var flicksErrorView: UIView!
    @IBOutlet weak var flicksErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.tmdbThumbnailImageUrl = self.tmdbImageBaseUrl + self.tmdbPosterSizes[0]
        //self.tmdbDetailImageUrl = self.tmdbImageBaseUrl + self.tmdbPosterSizes[4]
        
        flicksTableView.delegate = self
        flicksTableView.dataSource = self
        flicksSearchBar.delegate = self
        flicksErrorView.isHidden = true
        
        // Setup UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        
        // add refresh control to table view
        flicksTableView.insertSubview(refreshControl, at: 0)
        
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(self.tmdbApiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(
            configuration: .default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    
                    self.flicksSearchBar.isHidden = false
                    self.flicksTableView.isHidden = false
                    self.flicksErrorView.isHidden = true
                    
                    if let data = data {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                            
                            print("responseDictionary: \(responseDictionary)")
                            
                            // This is where you will store the returned array of posts in your posts property
                            self.flicks = responseDictionary["results"] as! [NSDictionary]
                            
                            self.flicksTableView.reloadData()
                            
                            // Hide HUD once the network request comes back (must be done on main UI thread)
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                    }
                    else {
                        //invalid data
                    }
                } else {
                    //Handle bad request and perform action
                    //let abc = 1
                    self.flicksSearchBar.isHidden = true
                    self.flicksTableView.isHidden = true
                    self.flicksErrorView.isHidden = false
                    
                    self.flicksErrorLabel.text = "Error loading movies data!"
                    
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Table view functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        flicksTableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if(searchActive) {
            count = self.searchedResults.count
        }
        else {
            count = self.flicks.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var list: [NSDictionary] = []
        let cell = flicksTableView.dequeueReusableCell(withIdentifier: "FlickTableViewCell") as! FlickTableViewCell
        
        if(searchActive) {
            list = self.searchedResults
        }
        else {
            list = self.flicks
        }
        
//        if self.searchedResults.count > 0 {
//            
//            let flick = self.searchedResults[indexPath.row]
//            
//            cell.flickTitleLabel.text = flick.value(forKeyPath: "title") as? String
//            cell.flickDescriptionLabel.text = flick.value(forKeyPath: "overview") as? String
//            
//            let posterPath = flick.value(forKeyPath: "poster_path") as? String
//            var imageUrlString = self.tmdbImageBaseUrl
//            imageUrlString.append(self.tmdbPosterSizes[0])
//            imageUrlString.append((posterPath)!)
//            if let imageUrl = URL(string: imageUrlString) {
//                
//                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
//                cell.flickImageUrlString = posterPath!
//                cell.flickImageView.setImageWith(imageUrl)
//                
//            } else {
//                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
//            }
//            
//        }
        
        if list.count > 0 {
            
            let flick = list[indexPath.row]
            
            cell.flickTitleLabel.text = flick.value(forKeyPath: "title") as? String
            cell.flickDescriptionLabel.text = flick.value(forKeyPath: "overview") as? String
            
            let posterPath = flick.value(forKeyPath: "poster_path") as? String
            var imageUrlString = self.tmdbImageBaseUrl
            imageUrlString.append(self.tmdbPosterSizes[0])
            imageUrlString.append((posterPath)!)
            if let imageUrl = URL(string: imageUrlString) {
                
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                cell.flickImageUrlString = posterPath!
                cell.flickImageView.setImageWith(imageUrl)
                
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        }
    
        // Configure YourCustomCell using the outlets that you've defined.
    
        return cell
    }

    // UIRefreshControl functions
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(self.tmdbApiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(
            configuration: .default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        print("responseDictionary: \(responseDictionary)")
                        
                        // This is where you will store the returned array of posts in your posts property
                        self.flicks = responseDictionary["results"] as! [NSDictionary]
                        
                        // Reload the tableView now that there is new data
                        self.flicksTableView.reloadData()
                        
                        // Tell the refreshControl to stop spinning
                        refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()
    }
    
    // Segue functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the index path from the cell that was tapped
        let indexPath = flicksTableView.indexPathForSelectedRow
        
        // Get the Row of the Index Path and set as index
        let index = indexPath?.row
        
        // Get in touch with the DetailViewController
        let detailViewController = segue.destination as! FlickDetailViewController
        
        // Pass on the data to the Detail ViewController by setting it's indexPathRow value
        var flick = flicks[index!]
        if(self.searchActive) {
            flick = self.searchedResults[index!]
        }
        
        //let cell = sender as! FlickTableViewCell
        var imageUrlString = self.tmdbImageBaseUrl
        imageUrlString.append(self.tmdbPosterSizes[4])
        imageUrlString.append(flick.value(forKey: "poster_path") as! String)
        detailViewController.imageUrlString = imageUrlString
        detailViewController.flickTitleString = flick.value(forKey: "title") as! String
        detailViewController.flickOverviewString = flick.value(forKey: "overview") as! String
        detailViewController.flickReleaseDateString = flick.value(forKey: "release_date") as! String
    }
    
    
    // SearchBar funtions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.searchedResults = self.flicks.filter {
                String(describing: $0["title"]).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        else {
            searchActive = false;
        }
        self.flicksTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    // Common functions
    /*
    class func fetchMovies(successCallBack: @escaping (NSDictionary) -> (), errorCallBack: ((Error?) -> ())?) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorCallBack?(error)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                
                print(dataDictionary)
                
                successCallBack(dataDictionary)
            }
        }
        task.resume()
    }
    */
    
    /*
    func fetchConfiguration() {
        
        
        let url = URL(string:"https://api.themoviedb.org/3/configuration?api_key=\(self.tmdbApiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(
            configuration: .default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        print("responseDictionary: \(responseDictionary)")
                        
                        // This is where you will store the returned array of posts in your posts property
//                        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
//                            
//                        self.tmdbImageBaseUrl = responseDictionary[0].value(forKey: "base_url") as? String
                    }
                }
        });
        task.resume()
    }
    */
    
    // TO DO
    // 1. update to use common function to fetch movies
    // 2. fetch configuration and cache

}
