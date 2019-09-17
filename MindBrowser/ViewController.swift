//
//  ViewController.swift
//  MindBrowser
//
//  Created by Apple on 15/09/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    var accessToken : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      self.getAccessToken()
    }
    func getAccessToken() {
        
        //RFC encoding of ConsumerKey and ConsumerSecretKey
        let encodedConsumerKeyString:String = "Sh4JYw4aQ773emLJTL9zlFFF2".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    let encodedConsumerSecretKeyString:String = "KYZk6x2O0HO8e1ClUyqDDMjXOnYJhjwHBXrY4PJ6M7OFBxkE7z".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        print(encodedConsumerKeyString)
        print(encodedConsumerSecretKeyString)
        //Combine both encodedConsumerKeyString & encodedConsumerSecretKeyString with " : "
        let combinedString = encodedConsumerKeyString+":"+encodedConsumerSecretKeyString
        print(combinedString)
        //Base64 encoding
        let data = combinedString.data(using: .utf8)
        let encodingString = "Basic "+(data?.base64EncodedString())!
        print(encodingString)
        //Create URL request
        var request = URLRequest(url: URL(string: "https://api.twitter.com/oauth2/token")!)
        request.httpMethod = "POST"
        request.setValue(encodingString, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let bodyData = "grant_type=client_credentials".data(using: .utf8)!
        request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
            print("error=\(String(describing: error))")
            return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let dictionary = data
            print("dictionary = \(dictionary)")
            print("responseString = \(String(describing: responseString!))")
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                print("Access Token response : \(response)")
                print(response["access_token"]!)
                self.accessToken = response["access_token"] as! String
                UserDefaults.standard.set( self.accessToken, forKey: "accessToken")
               
                
            } catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
    }

    
    
    @IBAction func loginToTwitterSocialMedia(_ sender: Any) {
        
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if session != nil{
                UserDefaults.standard.set(session?.userID, forKey: "userId")
                print(session?.userID)
                UserDefaults.standard.set(session?.userName, forKey: "userName")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                
                let client = TWTRAPIClient.withCurrentUser()
                let twitterClient = TWTRAPIClient(userID: session?.userID)
                twitterClient.loadUser(withID: session?.userID ?? "") { (user, error) in
                    print(user?.profileImageURL ?? "")
                    print(user?.profileImageLargeURL ?? "")
                    print(user?.screenName ?? "")
                    
                     UserDefaults.standard.set(user?.profileImageURL , forKey: "profileImage")
                        UserDefaults.standard.set(user?.screenName , forKey: "screenName")
                     UserDefaults.standard.set(user?.profileImageLargeURL, forKey: "profileImageUrl")
                }
                
                client.requestEmail { email, error in
                    if (email != nil) {
                        UserDefaults.standard.set(email, forKey: "email")
                        let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
                        self.present(mainNav!, animated: false, completion: nil)
                    } else {
                        print("error: \(error!.localizedDescription)");
                        let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
                        self.present(mainNav!, animated: false, completion: nil)
                    }
                }
            }else{
                print(error.debugDescription)
            }
        }
    }
    
}

