//
//  imageEffects.swift
//  Zoom Reader
//
//  Created by Howard Ellenberger on 12/30/19.
//  Copyright © 2019 Howard Ellenberger. All rights reserved.
//


import UIKit
import CoreImage
import CoreMedia
import AVFoundation


extension CameraViewController {
 
    func setupInputOutput() {
        do {
            //Camera
             if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                 //already authorized
             } else {
                 
             AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                 if granted {
                     //access allowed
                     print("Camera access allowed")
                 } else {
                     //access denied
                     print("Camera access denied")
                 }
                 })
             }
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Can't fetch back camera device")
                return
            }
    
            do {
                try self.backCamera?.lockForConfiguration()
    
                backCameraDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            } catch {
                print("Unable to obtain video device input")
                return
            }
            
            setupCorrectFramerate(currentCamera: backCamera)
            let captureDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
   func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
    
    for vFormat in backCamera!.formats {

           let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
           let frameRates = ranges[0]

           do {
               //set to 240fps - available types are: 30, 60, 120 and 240 and custom
               // lower framerates cause major stuttering
               if frameRates.maxFrameRate == 90 {
                   try backCamera!.lockForConfiguration()
                   backCamera!.activeFormat = vFormat as AVCaptureDevice.Format
                   //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
                   backCamera!.activeVideoMinFrameDuration = frameRates.minFrameDuration
                   backCamera!.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
               }
           }
           catch {
               print("Could not set active format")
               print(error)
           }
       }
   }
    
     public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

         if CMSampleBufferDataIsReady(sampleBuffer) == false {
             print("Sample buffer is not ready")
             return
         }

         if output is AVCaptureVideoDataOutput {
             videoOutput(output, didOutput: sampleBuffer, from: connection)
         }

        if (connection.isVideoStabilizationSupported) {
               connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.standard
           }
     }
    
     public func videoOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
             print("Can't create pixel buffer")
             return
        }
        var ciInput = CIImage(cvImageBuffer: pixelBuffer)

        DispatchQueue.main.async(execute: {

            if self.filterSegmentControl.selectedSegmentIndex == 0 {

                let controlsFilter = CIFilter(name: "CIColorControls")

                let value = NSNumber(value: 1.10)
                controlsFilter?.setValue(ciInput, forKey: kCIInputImageKey);
                controlsFilter?.setValue(value, forKey: "inputContrast")
                ciInput = (controlsFilter?.outputImage)!
                
                filter = self.sharpenLuminenceFilter
                filter = self.medianFilter
                filter = self.sharpenLuminenceFilter
                filter = self.tonalFilter
            }
            else {
                filter = self.sharpenLuminenceFilter
                filter = self.medianFilter
                filter = self.sharpenLuminenceFilter
            }
   

        // add filter to image
            filter?.setValue(ciInput, forKey: kCIInputImageKey)
            let ciOutput = filter?.value(forKey: kCIOutputImageKey) as! CIImage
            let ciContext = CIContext()
            let cgImage = ciContext.createCGImage(ciOutput, from: (ciOutput.extent))
        

            self.filteredImage.contentMode = .scaleAspectFill
            self.filteredImage.clipsToBounds = true

            let filterImage = UIImage(cgImage: cgImage!)

            self.filteredImage.image = filterImage
            })
            return

    }
}
