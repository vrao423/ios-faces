import UIKit
import Vision

extension CGImagePropertyOrientation {
  init(_ uiOrientation: UIImage.Orientation) {
    switch uiOrientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}

private extension CGMutablePath {
  // Helper function to add lines to a path.
  func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D,
                 applying affineTransform: CGAffineTransform,
                 closingWhenComplete closePath: Bool) {
    let pointCount = landmarkRegion.pointCount

    // Draw line if and only if path contains multiple points.
    guard pointCount > 1 else {
      return
    }
    self.addLines(between: landmarkRegion.normalizedPoints, transform: affineTransform)

    if closePath {
      self.closeSubpath()
    }
  }
}

func boundingBox(imageSize: CGSize, rect: CGRect) -> CGRect {
  let x = imageSize.width * rect.origin.x
  let y = imageSize.height - (rect.origin.y * imageSize.height)
  let width = imageSize.width * rect.width
  let height = -1.0 * imageSize.height * rect.height

  return CGRect(x: x,
                y: y,
                width: width,
                height: height)
}


func drawRectangleOnImage(image: UIImage, rects: [CGRect], color: UIColor = .green) -> UIImage {
  let imageSize = image.size
  let scale: CGFloat = 0
  UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
  let context = UIGraphicsGetCurrentContext()
  image.draw(at: CGPoint.zero)

  color.setStroke()
  for rect in rects {
    let rectangle = boundingBox(imageSize: imageSize, rect: rect)
    context?.stroke(rectangle, width: 10.0)
  }

  let newImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return newImage!
}

func detectFaces(image: UIImage) {
  let faceDetectRequest = VNDetectFaceRectanglesRequest(completionHandler: handleDetectedRectangles)
  runRequest(request: faceDetectRequest, image: image)
}

func detectFaceLandmarks(image: UIImage) {
  let faceLandmarksDetectRequest = VNDetectFaceLandmarksRequest(completionHandler: handleDetectedRectangles)
  runRequest(request: faceLandmarksDetectRequest, image: image)
}

func runRequest(request: VNRequest, image: UIImage) {
  let cgImage = image.cgImage!
  let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)

  let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                  orientation: cgOrientation,
                                                  options: [:])

  DispatchQueue.global(qos: .userInitiated).async {
    do {
      try imageRequestHandler.perform([request])
    } catch let error as NSError {
      print("Failed to perform image request: \(error)")
      return
    }
  }
}

func handleDetectedRectangles(request: VNRequest, _ error: Error?) {
  let faces = request.results as! [VNFaceObservation]

  let eyePoints: [[CGPoint]] = faces.map { face in
    let eyes = [face.landmarks?.leftEye, face.landmarks?.rightEye]
    let newEyes = eyes.compactMap { $0 }
    let points = newEyes.compactMap { $0.normalizedPoints.first }
    let normalizedPoints = points.map {
      CGPoint(x: face.boundingBox.minX + face.boundingBox.width * $0.x,
              y: face.boundingBox.minY + face.boundingBox.height * $0.y)
    }
    return normalizedPoints
  }

  let flatEyePoints = eyePoints.flatMap { $0 }
  let flatEyeRects = flatEyePoints.map { CGRect(x: $0.x, y: $0.y, width: 0.01, height: 0.01) }



  let newImage = image
  let faceRects = faces.map { $0.boundingBox }

  let finalImage = drawRectangleOnImage(image: newImage,
                                        rects: faceRects, color: .red)

  let eyesFinalImage2 = drawRectangleOnImage(image: finalImage,
                                             rects: flatEyeRects, color: .blue)
}

let image = UIImage(named: "group.jpeg")!

detectFaceLandmarks(image: image)





