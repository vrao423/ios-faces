//
//  FaceDetection.swift
//  Face_image
//
//  Created by Venkat Rao on 10/4/20.
//

import Foundation
import UIKit
import Vision

class FaceDetector {
  var image: UIImage?
  
  func performDetection() -> [CGRect]? {
    image = UIImage(named: "group_photo_1")
    let requestHandler = VNImageRequestHandler(cgImage: image!.cgImage!, options: [:])
  
    var boundingBoxes: [CGRect]?
    let request = VNDetectFaceRectanglesRequest { (request, error) in
      guard let results = request.results as? [VNFaceObservation] else {return}
      
      boundingBoxes = results.map { (faceObservation) -> CGRect in
        faceObservation.boundingBox
      }
    }
    
    try! requestHandler.perform([request])
    
    return boundingBoxes
  }
}
