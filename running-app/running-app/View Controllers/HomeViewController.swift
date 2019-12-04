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
    dashBoardButton.layer.cornerRadius = 10
    newRunButton.layer.cornerRadius = 10
    super.viewDidLoad()
  }
  
}

