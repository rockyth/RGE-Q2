//
//  ContentView.swift
//  My Images
//
//  Created by Stewart Lynch on 2021-08-08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    var body: some View {
        NavigationView {
            VStack {
                if let image = vm.image {
                    ZoomableScrollView {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.6)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal)
                }
                VStack {
                    if vm.labelVisible{
                        Text(String(vm.detectedFace))
                    }
                    //TextField("Image Name", text: $vm.imageName) { isEditing in
                    //    vm.isEditing = isEditing
                    //}
                    //.textFieldStyle(.roundedBorder)
                    HStack {
                        Button {
                            if vm.selectedImage == nil {
                                vm.detectFace(image: vm.image!)
                                //vm.addMyImage(vm.imageName, image: vm.image!)
                            }
                        } label: {
                            ButtonLabel(symbolName: vm.selectedImage == nil ? "square.and.arrow.down.fill" : "square.and.arrow.up.fill",
                                        label: "Detect Face")
                        }
                        .disabled(vm.buttonDisabled)
                        .opacity(vm.buttonDisabled ? 0.6 : 1)
                        if !vm.deleteButtonIsHidden {
                            Button {
                                
                            } label: {
                                ButtonLabel(symbolName: "trash", label: "Delete")
                            }
                        }
                    }
                    HStack {
                            Button {
                                vm.source = .camera
                                vm.showPhotoPicker()
                            } label: {
                                ButtonLabel(symbolName: "camera", label: "Camera")
                            }
                            Button {
                                vm.source = .library
                                vm.showPhotoPicker()
                            } label: {
                                ButtonLabel(symbolName: "photo", label: "Photos")
                            }
                    }
                }
                .padding()
                Spacer()
            }
            .sheet(isPresented: $vm.showPicker) {
                ImagePicker(sourceType: vm.source == .library ? .photoLibrary : .camera, selectedImage: $vm.image)
                    .ignoresSafeArea()
            }
            .alert("Error", isPresented: $vm.showCameraAlert, presenting: vm.cameraError, actions: { cameraError in
                cameraError.button
            }, message: { cameraError in
                Text(cameraError.message)
            })
            .navigationTitle("My Images")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
