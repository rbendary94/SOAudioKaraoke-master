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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
            print("----------------------------")
            getUserProfile()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
        
        print("Logged Out")
    }
//
    func getUserProfile () {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: "2.8")) { httpResponse, result in
            print("result == ", result)
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                print("Custom Graph Request Succeeded: \(response)")
                print("My facebook id is \(String(describing: response.dictionaryValue?["id"]))")
                print("My name is \(String(describing: response.dictionaryValue?["name"]))")
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        
        connection.start()
    }
  
}
