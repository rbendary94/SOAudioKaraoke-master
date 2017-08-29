//
//  LoginViewController.swift
//  SOAudioKaraoke
//
//  Created by Nesreen Mamdouh on 8/27/17.
//  Copyright © 2017 myCompany. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController,LoginButtonDelegate {

    var dict : [String : AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()

            let loginButton = LoginButton(readPermissions: [ .publicProfile , .userFriends ])
            loginButton.center = view.center
            loginButton.delegate = self
            view.addSubview(loginButton)
       
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("--------------Logged In--------------")
            print(grantedPermissions)
            print(declinedPermissions)
            print(accessToken)
            print("-------------------------------------")
            
            getUserProfile()
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
        print("Logged Out")
    }

    func getUserProfile () {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email,first_name, picture.type(small)"],accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: "2.8")) { httpResponse, result in
            print("result == ", result)
            switch result {
            case .success(let response):

                print("My facebook id is \(String(describing: response.dictionaryValue?["id"]))")
                print("My name is \(String(describing: response.dictionaryValue?["name"]))")
                print("My first name is \(String(describing: response.dictionaryValue?["first_name"]))")
                print("My profile pic url \(String(describing: response.dictionaryValue?["picture"]))")
               
                let name = (response.dictionaryValue?["name"] as? String) ?? ""
                let first_name = (response.dictionaryValue?["first_name"] as? String) ?? ""
                let id = (response.dictionaryValue?["id"] as? String) ?? ""
                
                
                var userInfoDict: [String:Any] = ["name":name]
                userInfoDict["first_name"] = first_name
                userInfoDict["id"] = id
            
                if let picture = response.dictionaryValue?["picture"] as? Dictionary<String, Any> {
                    
                    if let data = picture["data"] as? Dictionary<String, Any> {
                        if let url = data["url"] as? String {
                                print("URL ===> " , url)
                            userInfoDict["picUrlSmall"] = url
                        }
                    }
                }
              
                UserDefaults.standard.set(userInfoDict, forKey: "userInfoDict")
                UserDefaults.standard.synchronize()
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LyricsViewController")
                self.present(vc,animated: true,completion: nil)
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        
        connection.start()
    }
  
}
