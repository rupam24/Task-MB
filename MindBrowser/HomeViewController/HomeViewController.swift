//
//  HomeViewController.swift
//  MindBrowser
//
//  Created by Apple on 15/09/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var uiviewOutlet: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var friendListBtn: UIButton!
    
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
       
          self.navigationItem.title = "User Details"
        self.accessToken = UserDefaults.standard.string(forKey:"accessToken")
        getStatusesUserTimeline(accessToken: self.accessToken!)
        
        namelbl.text = UserDefaults.standard.string(forKey: "userName")
        if let email = UserDefaults.standard.string(forKey: "email")
        {
            emailLbl.text = email
        }
        else
        {
            emailLbl.text = ""
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.clipsToBounds = true
    
        let strImage1 =  UserDefaults.standard.string(forKey:"profileImageUrl")
        if let url = URL(string: strImage1!.replacingOccurrences(of: "", with: "%20"))
        {
            self.downloadImage(from: url, image:self.profileImage)
            
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.profileImage.isUserInteractionEnabled = true
        self.profileImage.addGestureRecognizer(tap)
        
        
        self.friendListBtn.layer.cornerRadius = 10
      
        self.uiviewOutlet.layer.shadowColor = UIColor.black.cgColor
        self.uiviewOutlet.layer.shadowOpacity = 1
        self.uiviewOutlet.layer.shadowOffset = .zero
        self.uiviewOutlet.layer.shadowRadius = 10
        
}
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "ImageProfileViewController")
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
        
    }
    func getStatusesUserTimeline(accessToken:String)
    {
        let userId = UserDefaults.standard.string(forKey:"userId")
        let screenName = UserDefaults.standard.string(forKey:"screenName")
        
        self.activityIndicator("Please wait...")
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
                                            self.followingCount.text = String("Followings \(self.arrayOfFriends.count)")
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
    
    
    @IBAction func friendListAct(_ sender: Any)
    {
        
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


    @IBAction func logoutAction(_ sender: Any)
    {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.present(loginVC!, animated: true, completion: nil)
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
