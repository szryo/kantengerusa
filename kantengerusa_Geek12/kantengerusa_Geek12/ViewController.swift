//
//  ViewController.swift
//  kantengerusa_Geek12
//
//  Created by kawanaka masaki on 2021/12/22.
//

import UIKit
import CoreMotion
import CoreML
import Firebase
import Charts

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    let classifier = ConsRateClassifier()
    var isStarted = false
    // Attitude data
    var outputlist:[Int] = [0,0,0]
    var outputNum:Int = 0
    var outputgraph:[Int] = [0]
    var dt = Date()
    let dateFormatter = DateFormatter()
    let db = Firestore.firestore()
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var linechart: LineChartView!
    @IBOutlet weak var Image1: UIImageView!
    @IBOutlet weak var record_stat: UILabel!
    var image1: UIImage!
    var image2: UIImage!
    var image_bad: UIImage!
    var image_normal: UIImage!
    var image_good: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classifier.delegate = self
        Button1.titleLabel?.font = UIFont.systemFont(ofSize: 23.0)
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
        startAccelerometer()
        stopAccelerometer()
        image1 = UIImage(named: "Record_stop")
        image2 = UIImage(named: "Record_start")
        image_bad = UIImage(named: "bad")
        image_normal = UIImage(named: "normal")
        image_good = UIImage(named: "good")
        Image1.image = image1
        record_stat.text = "録音待機中"
        setLineGraph()
    }
    
    @IBAction func RecordButton(_ sender: Any) {
        if isStarted{
            stopAccelerometer()
            Button1.setTitle("Start record", for: .normal)
            isStarted = false
            if (outputlist[0] >= outputlist[1] && outputlist[0] >= outputlist[2]){
                outputNum = 0
                Image1.image = image_bad
                record_stat.text = "もう少し集中しよう！"
            } else if (outputlist[1] >= outputlist[0] && outputlist[1] >= outputlist[2]){
                outputNum = 1
                Image1.image = image_normal
                record_stat.text = "そこそこ集中してたね！"
            } else {
                outputNum = 1
                Image1.image = image_good
                record_stat.text = "とても集中してました！"
            }
            print(outputgraph)
            db.collection("Cons").document("Result").setData([
                "Con_rate": outputNum
            ])
            setLineGraph()
        }
        else{
            outputgraph = []
            outputlist = [0,0,0]
            self.classifier.init_num()
            Image1.image = image2
            record_stat.text = "録音中"
            startAccelerometer()
            Button1.setTitle("Stop record", for: .normal)
            isStarted = true
        }
    }
    
    func startAccelerometer(){
        if(motionManager.isDeviceMotionAvailable){
            motionManager.deviceMotionUpdateInterval = 1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.classifier.process(deviceMotion: motion!)
            })
        }
    }
    
    func setLineGraph(){
        var entry = [ChartDataEntry]()
        
        for (i,d) in outputgraph.enumerated(){
            entry.append(ChartDataEntry(x: Double(i*20),y: Double(d)))
        }
        
        let dataset = LineChartDataSet(entries: entry)
        dataset.mode = .cubicBezier
                
        linechart.data = LineChartData(dataSet: dataset)
        
        linechart.leftAxis.axisMaximum = 2 //y左軸最大値
        linechart.leftAxis.axisMinimum = 0 //y左軸最小値
        linechart.leftAxis.labelCount = 2 // y軸ラベルの数
        linechart.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
    }
    
    func stopAccelerometer(){
        if (motionManager.isDeviceMotionAvailable){
            motionManager.stopDeviceMotionUpdates()
        }
    }
}

extension ViewController : ConsRateClassifierDelegate {
    func motionDidDetect(results: [(String, Double)]) {
        if (results[0].0 == "bad"){
            print("bad")
            outputlist[0] = outputlist[0] + 1
            outputgraph.append(0)
            //db.collection("Cons").document("Result").setData([
            //    "Con_rate": 0
            //])
        } else if (results[0].0 == "normal"){
            print("normal")
            outputlist[1] = outputlist[1] + 1
            outputgraph.append(1)
            //db.collection("Cons").document("Result").setData([
            //    "Con_rate": 1
            //])
        } else {
            print("good")
            outputlist[2] = outputlist[2] + 1
            outputgraph.append(2)
        }
    }
}
