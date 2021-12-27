//
//  ConsRateClassifier.swift
//  kantengerusa_Geek12
//
//  Created by kawanaka masaki on 2021/12/26.
//

import Foundation
import CoreML
import CoreMotion

protocol ConsRateClassifierDelegate: AnyObject {
    func motionDidDetect(results: [(String, Double)])
}

class ConsRateClassifier{
    weak var delegate: ConsRateClassifierDelegate?
    
    static let configuration = MLModelConfiguration()
    let model = try! MyConcentrationScoreClassifier_4(configuration: configuration)
    
    static let predictionWindowSize = 20
    
    var state = try! MLMultiArray(shape: [400] as [NSNumber], dataType: MLMultiArrayDataType.double)
    
    let Att_x = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let Att_y = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let Att_z = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let Rot_x = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let Rot_y = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let Rot_z = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    private var predictionWindowIndex = 0
    
    func init_num(){
        predictionWindowIndex = 0
    }
    
    func process(deviceMotion: CMDeviceMotion) {
        //print("bbb")
        if predictionWindowIndex == ConsRateClassifier.predictionWindowSize {
            return
        }
        Att_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.pitch as NSNumber
        Att_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.roll as NSNumber
        Att_z[[predictionWindowIndex] as [NSNumber]] =  deviceMotion.attitude.yaw as NSNumber
        Rot_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.x as NSNumber
        Rot_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.y as NSNumber
        Rot_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.z as NSNumber
        
        predictionWindowIndex += 1
        //print(predictionWindowIndex)
        
        if predictionWindowIndex == ConsRateClassifier.predictionWindowSize {
            DispatchQueue.global().async {
                self.predict()
                DispatchQueue.main.async {
                    self.predictionWindowIndex = 0
                }
            }
        }
    }
    var stateOut: MLMultiArray? = nil

    private func predict() {
        
        //print("ccc")

        let input = MyConcentrationScoreClassifier_4Input(
            AttX: Att_x,
            AttY: Att_y,
            AttZ: Att_z,
            RotX: Rot_x,
            RotY: Rot_y,
            RotZ: Rot_z,
            stateIn: state)
        
        guard let result = try? model.prediction(input: input) else { return }

        let sorted = result.labelProbability.sorted {
            return $0.value > $1.value
        }
        delegate?.motionDidDetect(results: sorted)
    }
}
