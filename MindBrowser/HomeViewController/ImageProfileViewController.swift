//
//  ImageProfileViewController.swift
//  MindBrowser
//
//  Created by Apple on 17/09/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SDWebImage
class ImageProfileViewController: UIViewController {

    @IBOutlet weak var profileImageHD: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBAction func closeView(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Profile"
        let strImage = UserDefaults.standard.string(forKey:"profileImageUrl")
        self.profileImageHD.sd_setImage(with: URL(string:strImage!), placeholderImage: UIImage(named: "placeholder.png"))
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
