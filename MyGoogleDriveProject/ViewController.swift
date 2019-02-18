//
//  ViewController.swift
//  MyGoogleDriveProject
//
//  Created by Nguyen Uy on 15/2/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class ViewController: UIViewController {
    fileprivate var googleAPIs: GoogleDriveAPI?
    var btnGoogleSignIn: GIDSignInButton?
    var btnDisconnect: UIButton?
    var btnListfile: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.btnGoogleSignIn = GIDSignInButton(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 50))
        self.view.addSubview(self.btnGoogleSignIn!)
        
        self.btnDisconnect = UIButton(frame: CGRect(x: 0, y: 300, width: self.view.frame.width, height: 50))
        self.btnDisconnect?.setTitle("Disconnect", for: .normal)
        self.btnDisconnect?.setTitleColor(UIColor.black, for: .normal)
        self.btnDisconnect?.addTarget(self, action: #selector(btnDisconnectTouchDown), for: .touchDown)
        self.view.addSubview(self.btnDisconnect!)
        
        self.btnListfile = UIButton(frame: CGRect(x: 0, y: 400, width: self.view.frame.width, height: 50))
        self.btnListfile?.setTitle("List files", for: .normal)
        self.btnListfile?.setTitleColor(UIColor.black, for: .normal)
        self.btnListfile?.addTarget(self, action: #selector(btnListFilesTouchDown), for: .touchDown)
        self.view.addSubview(self.btnListfile!)
        
        self.setupGoogleSignIn()
    }
    
    @objc
    private func btnListFilesTouchDown() {
        self.googleAPIs?.search("my folder name", onCompleted: { (fileItem, error) in
            guard error == nil, fileItem != nil else {
                return
            }
            guard let folderID = fileItem?.identifier else {
                return
            }
            self.googleAPIs?.listFiles(folderID, onCompleted: { (files, error) in
                print(error)
                print(files)
            })
        })
    }
    
    @objc
    private func btnDisconnectTouchDown() {
        GIDSignIn.sharedInstance()?.disconnect()
    }

    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.signInSilently()
    }
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            
        } else {
            print("Authenticate successfully")
            let service = GTLRDriveService()
            service.authorizer = user.authentication.fetcherAuthorizer()
            self.googleAPIs = GoogleDriveAPI(service: service)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Did disconnect to user")
    }
}

extension ViewController: GIDSignInUIDelegate {}

