//
//  ViewModel.swift
//  ViewModel
//
//  Created by Stewart Lynch on 2021-08-15.
//

import SwiftUI
import Vision

class ViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var showPicker = false
    @Published var source: Picker.Source = .library
    @Published var showCameraAlert = false
    @Published var cameraError: Picker.CameraErrorType?
    @Published var imageName: String = ""
    @Published var isEditing = false
    @Published var selectedImage: MyImage?
    @Published var myImages: [MyImage] = []
    @Published var showFileAlert = false
    @Published var appError: MyImageError.ErrorType?
    @Published var detectedFace: Int = 0
    @Published var labelVisible = false
    
    init() {
        print(FileManager.docDirURL.path)
    }
    
    var buttonDisabled: Bool {
        //imageName.isEmpty || image == nil
        if image == nil{
            return true
        }else {return false}
    }
    
    var deleteButtonIsHidden: Bool {
        isEditing || selectedImage == nil
    }
    
    func showPhotoPicker() {
        do {
            if source == .camera {
                try Picker.checkPermissions()
            }
            showPicker = true
        } catch {
            showCameraAlert = true
            cameraError = Picker.CameraErrorType(error: error as! Picker.PickerError)
        }
    }
    
    func reset() {
        image = nil
        imageName = ""
    }
    
    func setupVision(image: CGImage){
        let faceDetectionRequest = VNDetectFaceRectanglesRequest (completionHandler: self.handleFaceDetectionRequest)
        let imageRequestHandler = VNImageRequestHandler(cgImage: image)
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        }catch let error as NSError{
            print(error)
            return
        }
    }
    
    func handleFaceDetectionRequest (request: VNRequest?, error: Error?){
        if let requestError = error as NSError?{
            print(requestError)
            return
        }
        if let results = request?.results as? [VNFaceObservation]{
            self.labelVisible = true
            self.detectedFace = results.count
        }
    }
    
    func detectFace(image: UIImage){
        guard let cgImage = image.cgImage else {return}
        setupVision(image: cgImage)
    }
                                                                   
    func addMyImage(_ name: String, image: UIImage) {
        reset()
        let myImage = MyImage(name: name)
        do {
            try FileManager().saveImage("\(myImage.id)", image: image)
            myImages.append(myImage)
            saveMyImagesJSONFile()
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: error as! MyImageError)
        }
    }
    
    func saveMyImagesJSONFile() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(myImages)
            let jsonString = String(decoding: data, as: UTF8.self)
            do {
                try FileManager().saveDocument(contents: jsonString)
            } catch {
                showFileAlert = true
                appError = MyImageError.ErrorType(error: error as! MyImageError)
            }
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: .encodingError)
        }
    }
}
