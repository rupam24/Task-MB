//
//  FriendListViewController.swift
//  MindBrowser
//
//  Created by Apple on 15/09/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import TwitterKit
import SDWebImage
class FriendListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    var accessToken : String?
    var arrayOfFriends = [FriendListObject]()
    var strLabel = UILabel()
    var contentView = UIView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var activityIndicator: UIActivityIndicatorView?
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator?.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 1, alpha: 1)
        
        effectView.frame = CGRect(x: self.view.frame.midX - strLabel.frame.width/2, y: self.view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator!)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //title
        self.navigationItem.title = "Friend List"
        //Set delegate table
        self.tableViewOutlet.delegate = self
        self.tableViewOutlet.dataSource = self
        
        //access token
        
        self.accessToken = UserDefaults.standard.string(forKey:"accessToken")
        self.getStatusesUserTimeline(accessToken:self.accessToken!)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendTableViewCell
        var temp = FriendListObject()
        temp = self.arrayOfFriends[indexPath.row]
        cell.nameLbl.text = temp.nameStr
        let strImage = temp.profileStr
        
        // image set
        cell.profileImageView.sd_setImage(with: URL(string:strImage!), placeholderImage: UIImage(named: "placeholder.png"))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func getStatusesUserTimeline(accessToken:String)
    {
        let userId = UserDefaults.standard.string(forKey:"userId")
        let screenName = UserDefaults.standard.string(forKey:"screenName")
        self.activityIndicator("please wait..")
        let twitterClient = TWTRAPIClient(userID: userId)
        twitterClient.loadUser(withID: userId!) { (user, error) in
            if user != nil
            {
                //Get users timeline tweets
                var request = URLRequest(url: URL(string: "https://api.twitter.com/1.1/friends/list.json?screen_name=\(screenName!)&count=100")!)
                request.httpMethod = "GET"
                request.setValue("Bearer "+self.accessToken!, forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(String(describing: response))")
                        
                    }
                    
                    do {
                        
                        let rootDic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if (rootDic != nil)
                        {
                            let rootArr = rootDic?.value(forKey: "users") as? NSArray
                            
                            if rootArr != nil
                            {
                                for item in rootArr!
                                {
                                    var temp = FriendListObject()
                                    var dict = item as! NSDictionary
                                    
                                    if (dict.value(forKey: "") as? String == "No data Found")
                                    {
                                        DispatchQueue.main.async()
                                            {
                                                 self.effectView.removeFromSuperview()
                                                var loginAlert = UIAlertController(title: "Error", message: "No Data Found", preferredStyle: .alert)
                                                var loginAlertAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                                                    self.navigationController?.popViewController(animated: false)
                                                })
                                                loginAlert.addAction(loginAlertAction)
                                                self.present(loginAlert, animated: true, completion: nil)
                                        }
                                    }
                                    else
                                    {
                                        
                                        temp.nameStr = (dict.value(forKey: "name") as? String) ?? ""
                                        temp.profileStr = (dict.value(forKey: "profile_image_url_https") as? String) ?? ""
                                        
                                        
                                        self.arrayOfFriends.append(temp)
                                    }
                                    DispatchQueue.main.async
                                        {
                                             self.effectView.removeFromSuperview()
                                            self.tableViewOutlet.reloadData()
                                    }
                                }
                                
                                
                            }
                            else
                            {
                                print("error")
                                DispatchQueue.main.async()
                                    {
                                         self.effectView.removeFromSuperview()
                                        var loginAlert = UIAlertController(title: "Error", message: "No Data Found", preferredStyle: .alert)
                                        var loginAlertAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                                            self.navigationController?.popViewController(animated: false)
                                        })
                                        loginAlert.addAction(loginAlertAction)
                                        self.present(loginAlert, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        else
                        {
                            print("error")
                            self.effectView.removeFromSuperview()
                        }
                        
                        
                    }
                    catch let error as NSError {
                        print(error)
                    }
                }
                
                task.resume()
                
            }
        }
        
    }
    
    
    
    
    func downloadImage(from url: URL,image: UIImageView) {
        
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.sync(execute: { () -> Void in
                let myImage = UIImage(data: data)
                image.image = myImage
            })
            
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
