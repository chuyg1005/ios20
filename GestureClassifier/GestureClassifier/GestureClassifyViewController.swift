/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreML
import CoreMotion

class GestureClassifyViewController: UIViewController {
  
  struct Config {
    static let windowSize = ModelConstants.windowSize
    static let windowOffset = 5
    static let numberOfWindows = windowSize / windowOffset
    static let bufferSize = windowSize + windowOffset * (numberOfWindows - 1)
    static let samplesPerSecond = 25.0
    static let windowOffsetAsBytes = windowOffset * 8
    static let windowSizeAsBytes = windowSize * 8
  }
  
  let motionManager = CMMotionManager()
  let queue = OperationQueue()
  
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var toggleButton: UIButton!
  
  let rotX = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  let rotY = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  let rotZ = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  let accelX = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  let accelY = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  let accelZ = try! MLMultiArray(shape: [Config.bufferSize as NSNumber], dataType: .double)
  
  let modelInput = (
    rotX: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double),
    rotY: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double),
    rotZ: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double),
    accelX: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double),
    accelY: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double),
    accelZ: try! MLMultiArray(shape: [Config.windowSize as NSNumber], dataType: .double))
  
  let clf = Classifier()
  
  var bufferIndex = 0 {
    willSet {
      if newValue == 0 {
        isDataAvaliable = true
      }
    }
    didSet {
      tryToPredict()
    }
  }
  
  var isDataAvaliable = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  func buffer(motionData: CMDeviceMotion) {
    for offset in [0, Config.windowSize] {
      let index = bufferIndex + offset
      if index >= Config.bufferSize {
        continue
      }
      rotX[index] = motionData.rotationRate.x as NSNumber
      rotY[index] = motionData.rotationRate.y as NSNumber
      rotZ[index] = motionData.rotationRate.z as NSNumber
      accelX[index] = motionData.userAcceleration.x as NSNumber
      accelY[index] = motionData.userAcceleration.y as NSNumber
      accelZ[index] = motionData.userAcceleration.z as NSNumber
    }
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  @IBAction func switchMotion(_ sender: UIButton) {
    if sender.currentTitle == "start" {
      enableMotionUpdates()
      sender.setTitle("finish", for: .normal)
    } else {
      disableMotionUpdates()
      self.resultLabel.text = "识别结果"
      sender.setTitle("start", for: .normal)
    }
  }
  
  func enableMotionUpdates() {
    // 1
    motionManager.deviceMotionUpdateInterval =
      1 / Config.samplesPerSecond
    // 3
    motionManager.startDeviceMotionUpdates(
      using: .xArbitraryZVertical,
      to: queue) { [weak self] motionData, error in
        // 4
        guard let self = self, let motionData = motionData else {
          let errorText = error?.localizedDescription ?? "Unknown"
          print("Device motion update error: \(errorText)")
          return
        }
        // 5
        self.buffer(motionData: motionData)
        self.bufferIndex = (self.bufferIndex + 1) % Config.windowSize
    }
  }
  
  func disableMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }
  
  func tryToPredict() {
    if isDataAvaliable &&
      bufferIndex % Config.windowOffset == 0 &&
      bufferIndex + Config.windowOffset <= Config.windowSize {
      let window = bufferIndex / Config.windowOffset
      memcpy(modelInput.rotX.dataPointer, rotX.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      memcpy(modelInput.rotY.dataPointer, rotY.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      memcpy(modelInput.rotZ.dataPointer, rotZ.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      memcpy(modelInput.accelX.dataPointer, accelX.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      memcpy(modelInput.accelY.dataPointer, accelY.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      memcpy(modelInput.accelZ.dataPointer, accelZ.dataPointer.advanced(by: window*Config.windowOffsetAsBytes), Config.windowSizeAsBytes)
      
      let activity = clf.predict(rotX: modelInput.rotX, rotY: modelInput.rotY, rotZ: modelInput.rotZ, accelX: modelInput.accelX, accelY: modelInput.accelY, accelZ: modelInput.accelZ)
      
      
      DispatchQueue.main.async {[weak self] in
        guard let self = self else {
          return
        }
        var text = "unknown activity"
        if let activity = activity {
          switch activity {
          case "rest_it":
            text = "You are resting."
          case "shake_it":
            text = "You are shaking."
          case "chop_it":
            text = "You are chopping."
          case "drive_it":
            text = "You are driving."
          default:
            break
          }
        }
        self.resultLabel.text = text
      }
    }
  }
}
