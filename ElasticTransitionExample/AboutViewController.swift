//
//  AboutViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit


func getRandomColor() -> UIColor{
  let randomRed:CGFloat = CGFloat(drand48())
  let randomGreen:CGFloat = CGFloat(drand48())
  let randomBlue:CGFloat = CGFloat(drand48())
  return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}

class AboutViewController: UIViewController, ElasticMenuTransitionDelegate {
  var dismissByForegroundDrag: Bool = true

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = getRandomColor()
  }
  
  @IBAction func dismiss(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }


  override var preferredStatusBarStyle: UIStatusBarStyle { return UIStatusBarStyle.lightContent }
}
