//
//  ViewController.swift
//  FencingDemo
//
//  Created by Jacob Bailey on 8/12/17.
//  Copyright © 2017 Jacob Bailey. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let motionManger = CMMotionManager()
    let interval = 0.1
    var timer = Timer()
    let altimeter = CMAltimeter()
    let motionActivityManager = CMMotionActivityManager()
    var isSafe = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isDeviceAvailable() {
            print("Core Motion Launched")
            startSafetyCheck()
            myDeviceMotion()
//            myAltimeter()
//            myMagnetometer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManger.stopDeviceMotionUpdates()
        timer.invalidate()
        altimeter.stopRelativeAltitudeUpdates()
        motionManger.stopMagnetometerUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isDeviceAvailable() -> Bool {
//        let gyroAvaiable = motionManger.isGyroAvailable
//        let accelAvaiable = motionManger.isAccelerometerAvailable
        if !motionManger.isDeviceMotionAvailable {
            let alert = UIAlertController(title: "Fencing", message: "Your device does not have the necessary sensors. You might want to try on another device.", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            print("Device is not detected.")
        }
        return motionManger.isDeviceMotionAvailable
    }
    
    func myDeviceMotion() {
        motionManger.deviceMotionUpdateInterval = interval
        motionManger.startDeviceMotionUpdates()
        startTimer()
//        motionManger.startDeviceMotionUpdates(to: OperationQueue.main) { (deviceMotion, error) in
//            if let deviceMotion = deviceMotion {
//                print("\(deviceMotion.userAcceleration.x) \(Date())")
//            }
//        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
            self.safetyCheck()
            if let deviceMotion = self.motionManger.deviceMotion {
                let accel = deviceMotion.userAcceleration
                print(String(format:"X: %7.4 Y: %7.4f",accel.x, accel.y))
                let rot = deviceMotion.attitude
                if rot.pitch > 1.4 && rot.pitch < 1.57 {
                    print("Salute -------ON GARDE!!!")
                }
                if accel.y >= 2.0 {
                    var gyro = CMRotationRate()
                    if self.motionManger.isGyroAvailable {
                        gyro = deviceMotion.rotationRate
                        print(String(format:"Rotation Rate Z: %7.4f", gyro.z))
                    } else {
                        print("Gyro not available yet")
                    }
                    var slashAxis = gyro.z
                    if abs(rot.roll) > 0.79 {
                        slashAxis = gyro.x
                    }
                    if slashAxis > 4.0 || slashAxis < -4.0 {
                        print("////Slash\\\\")
                    }
                    
                    print("******Thrust********")
                } else {
                    var parryAxis = accel.x
                    if abs(rot.roll) > 0.79 {
                        parryAxis = accel.z
                    }
                    if parryAxis <= -1.0 || parryAxis >= 1.0 {
                        print("======Parry======")
                    }
                }
                
            }
        })
    }
    
    func myAltimeter() {
        var first = true
        var firstPressure = 0.0
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitude, error) in
                if let altitude = altitude {
                    let pressure = altitude.pressure as! Double
                    let relAltitude = altitude.relativeAltitude as! Double
                    if first {
                        firstPressure = pressure
                        first = false
                    }
                    let pressureChange = firstPressure - pressure
                    print("Pressure \(pressure) Pressure Change \(pressureChange) Altitude Change \(relAltitude)")
                }
            })
        } else {
            print("No Altimeter")
        }
    }
    
    func myMagnetometer() {
        if motionManger.isMagnetometerAvailable {
            motionManger.magnetometerUpdateInterval = 0.05
            motionManger.startMagnetometerUpdates(to: OperationQueue.main, withHandler: { (magnetometer, error) in
                if self.motionManger.isMagnetometerActive {
                    if let field = magnetometer?.magneticField {
                        print(String(format:"Raw: X: %10.4f Y: %10.4f Z: %10.4f", field.x, field.y, field.z))
                        return
                    }
                }
                print("Raw magnetometer not active")
            })
        } else {
            print("Magnetometer Not Available")
        }
    }
    
    func startSafetyCheck() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (motionActivity) in
                if let activity = motionActivity {
                    if activity.confidence == .high || activity.confidence == .medium {
                        print("High Confidence")
                        if activity.running {
                            self.isSafe = false
                        } else {
                            self.isSafe = true
                        }
                    }
                }
            })
        }
    }
    
    func safetyCheck() {
        if isSafe == false {
            timer.invalidate()
            print("Don't run with a sword!!")
            let alert = UIAlertController(title: "Be safe!!", message: "Running around with a sword is not a safe thing to do", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
                self.isSafe = true
                self.startTimer()
            })
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    }
}




























































































