//
//  ViewController.swift
//  Acceleration_collection
//
//  Created by kawanaka masaki on 2021/12/02.
//

import UIKit
import CoreMotion
import Firebase

class ViewController: UIViewController {
    let motionManager = CMMotionManager()
    var isStarted = true
    var isSaved = false
    // User acceleration data
    var Acc_data_x:[Double] = []
    var Acc_data_y:[Double] = []
    var Acc_data_z:[Double] = []
    // Attitude data
    var Att_data_x:[Double] = []
    var Att_data_y:[Double] = []
    var Att_data_z:[Double] = []
    // Gravity data
    var Gra_data_x:[Double] = []
    var Gra_data_y:[Double] = []
    var Gra_data_z:[Double] = []
    // Rotation rate data
    var Rot_data_x:[Double] = []
    var Rot_data_y:[Double] = []
    var Rot_data_z:[Double] = []
    let db = Firestore.firestore()
    var dt = Date()
    let dateFormatter = DateFormatter()
    var document_name:String = "bad"

    
    @IBOutlet weak var AccX: UILabel!
    @IBOutlet weak var AccY: UILabel!
    @IBOutlet weak var AccZ: UILabel!
    @IBOutlet weak var AttX: UILabel!
    @IBOutlet weak var AttY: UILabel!
    @IBOutlet weak var AttZ: UILabel!
    @IBOutlet weak var GraX: UILabel!
    @IBOutlet weak var GraY: UILabel!
    @IBOutlet weak var GraZ: UILabel!
    @IBOutlet weak var RotX: UILabel!
    @IBOutlet weak var RotY: UILabel!
    @IBOutlet weak var RotZ: UILabel!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var Conratio_SegControl: UISegmentedControl!
    @IBOutlet weak var SaveText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
        startAccelerometer()
        stopAccelerometer()
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        if isStarted{
            stopAccelerometer()
            StartButton.setTitle("Start record", for: .normal)
            isStarted=false
            isSaved = true
        }
        else{
            self.SaveText.text = ""
            data_clear()
            startAccelerometer()
            StartButton.setTitle("Stop record", for: .normal)
            isStarted=true
            isSaved = false
        }
    }

    @IBAction func saveButton(_ sender: Any) {
        if isSaved{
            setAccFirebase()
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        if let title = Conratio_SegControl.titleForSegment(at: Conratio_SegControl.selectedSegmentIndex){
            document_name = title
        }
    }
    
    
    func outputMotionData(deviceMotion: CMDeviceMotion){
        AccX.text = "AccX: " + String(format: "%04f", deviceMotion.userAcceleration.x)
        AccY.text = "AccY: " + String(format: "%04f", deviceMotion.userAcceleration.y)
        AccZ.text = "AccZ: " + String(format: "%04f", deviceMotion.userAcceleration.z)
        AttX.text = "AttX: " + String(format: "%04f", deviceMotion.attitude.pitch)
        AttY.text = "AttY: " + String(format: "%04f", deviceMotion.attitude.roll)
        AttZ.text = "AttZ: " + String(format: "%04f", deviceMotion.attitude.yaw)
        GraX.text = "GraX: " + String(format: "%04f", deviceMotion.gravity.x)
        GraY.text = "GraY: " + String(format: "%04f", deviceMotion.gravity.y)
        GraZ.text = "GraZ: " + String(format: "%04f", deviceMotion.gravity.z)
        RotX.text = "RotX: " + String(format: "%04f", deviceMotion.rotationRate.x)
        RotY.text = "RotY: " + String(format: "%04f", deviceMotion.rotationRate.y)
        RotZ.text = "RotZ: " + String(format: "%04f", deviceMotion.rotationRate.z)
        Acc_data_x.append(deviceMotion.userAcceleration.x)
        Acc_data_y.append(deviceMotion.userAcceleration.y)
        Acc_data_z.append(deviceMotion.userAcceleration.z)
        Att_data_x.append(deviceMotion.attitude.pitch)
        Att_data_y.append(deviceMotion.attitude.roll)
        Att_data_z.append(deviceMotion.attitude.yaw)
        Gra_data_x.append(deviceMotion.gravity.x)
        Gra_data_y.append(deviceMotion.gravity.y)
        Gra_data_z.append(deviceMotion.gravity.z)
        Rot_data_x.append(deviceMotion.rotationRate.x)
        Rot_data_y.append(deviceMotion.rotationRate.y)
        Rot_data_z.append(deviceMotion.rotationRate.z)
        
    }
    
    func stopAccelerometer(){
        if (motionManager.isDeviceMotionAvailable){
            motionManager.stopAccelerometerUpdates()
        }
        isStarted = false
    }
    
    
    func data_clear(){
        Acc_data_x = []
        Acc_data_y = []
        Acc_data_z = []
        Att_data_x = []
        Att_data_y = []
        Att_data_z = []
        Gra_data_x = []
        Gra_data_y = []
        Gra_data_z = []
        Rot_data_x = []
        Rot_data_y = []
        Rot_data_z = []
    }
    
    func startAccelerometer(){
        if(motionManager.isDeviceMotionAvailable){
            motionManager.deviceMotionUpdateInterval = 1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                        self.outputMotionData(deviceMotion: motion!)
            })
        }
    }
    
    func setAccFirebase(){
        isSaved = false
        dt = Date()
        db.collection("AccResult").document(document_name).collection("data").document(dateFormatter.string(from: dt)).setData([
            "AccX": Acc_data_x,
            "AccY": Acc_data_y,
            "AccZ": Acc_data_z,
            "AttX": Att_data_x,
            "AttY": Att_data_y,
            "AttZ": Att_data_z,
            "GraX": Gra_data_x,
            "GraY": Gra_data_y,
            "GraZ": Gra_data_z,
            "RotX": Rot_data_x,
            "RotY": Rot_data_y,
            "RotZ": Rot_data_z
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                self.SaveText.text = "Error writing document"
            } else {
                print("Document successfully written!")
                self.SaveText.text = "Document successfully written!"
            }
        }
    }
}

