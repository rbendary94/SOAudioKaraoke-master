//
//  TestLoginViewController.swift
//  SOAudioKaraoke
//
//  Created by Rana on 8/27/17.
//  Copyright © 2017 myCompany. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin


class TestLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    //Some other options: "user_about_me", "user_birthday", "user_hometown", "user_likes", "user_interests", "user_photos", "friends_photos", "friends_hometown", "friends_location", "friends_education_history"
    
    func loginToFacebookWithSuccess(successBlock: @escaping () -> (), andFailure failureBlock: @escaping (NSError?) -> ()) {
        
        if AccessToken.current != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        
        
        LoginManager().logIn([.publicProfile, .email , .userFriends], viewController: self, completion: { (result) -> Void in
            
            switch result {
            
            case .failed(let error):
                print(error)
                LoginManager().logOut()
                failureBlock(error as NSError)
     
            case .cancelled:
                print("User cancelled login.")
                LoginManager().logOut()
                failureBlock(nil)
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                let token = accessToken
                print("Logged in!", token.authenticationToken)
//                self.getUserProfile()
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing

                
                if grantedPermissions != nil {
                    let fbUserID = token.userId
                    
                    //Send fbToken and fbUserID to your web API for processing, or just hang on to that locally if needed
                    //self.post("myserver/myendpoint", parameters: ["token": fbToken, "userID": fbUserId]) {(error: NSError?) ->() in
                    //	if error != nil {
                    //		failureBlock(error)
                    //	} else {
                    //		successBlock(maybeSomeInfoHere?)
                    //	}
                    //}
                    
                    successBlock()

                }else{
                    failureBlock((nil))

                }
                
            }

        })

    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
