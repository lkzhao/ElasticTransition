//
//  NavigationExampleViewController.swift
//  ElasticTransitionExample
//
//  Created by Livio Gamassia on 20/03/2017.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation
import UIKit

class NavigationExampleViewController: UIViewController {
    let rgr = UIScreenEdgePanGestureRecognizer()

    var transition = ElasticTransition()

    override func viewDidLoad() {
        super.viewDidLoad()

        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .translateMid

        // gesture recognizer
        rgr.addTarget(self, action: #selector(InitialViewController.handleRightPan(_:)))
        rgr.edges = .right
        view.addGestureRecognizer(rgr)

        view.backgroundColor = getRandomColor()
    }

    func handleRightPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            navigationController?.delegate = transition
            transition.edge = .right
            transition.navigation = true
            let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigationExample") as! NavigationExampleViewController
            transition.startInteractiveTransition(self, toViewController: nextViewController, gestureRecognizer: pan)
        } else {
            _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showMore(_ sender: AnyObject) {
        let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigationExample") as! NavigationExampleViewController
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
