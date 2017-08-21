//
//  ViewController.swift
//  Demo
//
//  Created by luhao on 2017/8/13.
//  Copyright © 2017年 luhao. All rights reserved.
//

import UIKit
import SporeNetworking
import Result

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var loadArea: MogoAPIs.HotBusinessAreaAPI = MogoAPIs.HotBusinessAreaAPI.init()
        
        let _ = Spore.send(loadArea, callbackQueue: .main) {
            (result: Result<BusinessArea, SessionTaskError>) in
            
            print("call back")
            
            switch result {
            case .success(let user):
                print("\(user)")
            case .failure(let sessionError):
                print("\(sessionError)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

