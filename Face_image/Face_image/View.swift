//
//  View.swift
//  Face_image
//
//  Created by Venkat Rao on 10/4/20.
//

import UIKit

class View: UIView {
  
  let imageView: UIImageView
  var boundingBoxes: [CGRect]?
  var boxes = [UIView()]
  
  override init(frame: CGRect) {
    imageView = UIImageView(frame: .zero)
    super.init(frame: frame)

    imageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    
    NSLayoutConstraint.activate([
      imageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
      imageView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
      imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
    ])
    imageView.image = UIImage(named: "group_photo_1")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    boxes.forEach { (view) in
      view.removeFromSuperview()
    }
    
    boxes = []
    
    let layoutFrame = safeAreaLayoutGuide.layoutFrame
    let imageSize = imageView.image!.size
    let ratioWidth = layoutFrame.width / imageSize.width
    let ratioHeight = layoutFrame.height / imageSize.height
    
    var frame = layoutFrame
    let box = UIView(frame: layoutFrame)
    if ratioWidth > ratioHeight {
      frame.origin.x = (layoutFrame.width - ratioHeight * imageSize.width) / 2.0
      frame.size.width = ratioHeight * imageSize.width
    } else {
      frame.origin.y = (layoutFrame.height - ratioWidth * imageSize.height) / 2.0
      frame.size.height = ratioWidth * imageSize.height
    }
    box.frame = frame
    imageView.addSubview(box)
    box.backgroundColor = .clear
    box.layer.borderColor = UIColor.green.cgColor
    box.layer.borderWidth = 2.0
    
    boxes.append(box)
    
    for faceBoundingBox in boundingBoxes! {
      let faceBox = UIView(frame: box.frame)
      faceBox.backgroundColor = .clear
      faceBox.layer.borderColor = UIColor.green.cgColor
      faceBox.layer.borderWidth = 2.0
      
      var frame = faceBox.frame
      frame.origin = CGPoint(x: frame.minX + frame.width * faceBoundingBox.minX,
                             y: frame.minY + frame.height * (1.0 - (faceBoundingBox.minY + faceBoundingBox.height)))
      frame.size = CGSize(width: faceBoundingBox.width * frame.width, height: faceBoundingBox.height * frame.height)
      faceBox.frame = frame
      imageView.addSubview(faceBox)
      
      boxes.append(faceBox)
    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
