//
//  ViewController.swift
//  Face_image
//
//  Created by Venkat Rao on 10/4/20.
//

import UIKit

class ViewController: UIViewController {
  var currentView: View?
  
  override func loadView() {
    currentView = View(frame: .zero)
    view = currentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    let request = FaceDetector()
    let rects = request.performDetection()
        
    currentView?.boundingBoxes = rects
  }
  
}

