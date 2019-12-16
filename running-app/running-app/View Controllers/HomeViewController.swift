//
//  HomeViewController.swift
//  running-app
//
//  Created by Nicolas Kesseli on 02.12.19.
//  Copyright © 2019 Nicolas Kesseli. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  
    @IBOutlet weak var dashBoardButton: UIButton!
    @IBOutlet weak var newRunButton: UIButton!
    override func viewDidLoad() {
 
    super.viewDidLoad()
        
        tabBarController?.tabBar.items![0].title = "Home Screen"
        tabBarController?.tabBar.items![1].title = "Neuer Run"
        tabBarController?.tabBar.items![2].title = "Dashboard"
        tabBarController?.tabBar.items![0].image = #imageLiteral(resourceName: "home25.png")
        tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "running25.png")
        tabBarController?.tabBar.items![2].image = #imageLiteral(resourceName: "dashboard25.png")
  }
  
}

