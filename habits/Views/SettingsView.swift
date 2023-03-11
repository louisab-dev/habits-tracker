//
//  SettingsView.swift
//  habit-tracker
//
//  Created by Louis AB on 27/02/2023.
//

import Supabase
import SupabaseStorage
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var userSettingsContentModel: UserSettingsContentModel

    @State private var showModal = false
    @State private var username = ""

    let client = SupabaseClient(supabaseURL: URL(string: Constants.supabaseUrl)!,
                                supabaseKey: Constants.supabaseKey)

    func logOut() {
        Task {
            do {
                try await client.auth.signOut()
                model.loggedIn = false
            } catch {
                print("### Session Error: \(error)")
            }
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(Color("Background"))

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 0) {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        logOut()
                    }) {
                        Text("Logout")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .accentColor(.white)
                    .background(
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(Color("Gray"))
                    )
                    .padding(.horizontal)
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)

                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Hey \(userSettingsContentModel.username)")
                                .font(.title)
                                .foregroundColor(.white)

                            // Spacer()
                        }

                        Button(action: {
                            showModal = true
                        }, label: {
                            Text("Update username")
                                .foregroundColor(.white)
                                .font(.headline)
                        })
                        .padding(5)
                        .background(
                            Rectangle()
                                .cornerRadius(10)
                                .foregroundColor(Color("Gray"))
                        )
                        .sheet(isPresented: $showModal) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color("Background"))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .ignoresSafeArea()

                                VStack {
                                    TextField("Enter new username", text: $username)
                                        .padding()
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("Save") {
                                        Task {
                                            await userSettingsContentModel.updateUsername(newUsername: username)
                                        }
                                        showModal = false
                                    }
                                    .padding()
                                    .background(Color("Gray"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10.0)
                                }
                                .padding()
                            }
                        }
                    }

                    Spacer()

                    ProfilePictureView(client: client)
                        .environmentObject(userSettingsContentModel)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
        .task {
            await userSettingsContentModel.setProfilePicture()
        }
    }
}

struct ProfilePictureView: View {
    @State private var profilePicture: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imageLoaded = false

    @EnvironmentObject var userSettingsContentModel: UserSettingsContentModel

    let timeout: TimeInterval = 4

    var client: SupabaseClient

    var body: some View {
        VStack {
            VStack {
                if true || userSettingsContentModel.userHasProfilePicture {
                    AsyncImage(url: URL(string: userSettingsContentModel.userProfilePictureURL)) { image in
                        image.resizable()
                            .clipShape(
                                Circle()
                            )
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .clipShape(Circle())
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .frame(width: 75, height: 75)
                    .overlay(
                        Circle()
                            .stroke(Color("Purple"), lineWidth: 2)
                    )
                } else {
                    if let image = profilePicture {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                    }
                }

                Button(action: {
                    self.showImagePicker = true
                }, label: {
                    Text("Change Photo")
                        .foregroundColor(.white)
                        .font(.headline)
                })
                .padding(5)
                .background(
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(Color("Gray"))
                )
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage, content: {
            ImagePicker(image: $profilePicture)
                .environmentObject(userSettingsContentModel)
        })
    }

    func loadImage() {
        guard let selectedImage = profilePicture else { return }
        profilePicture = selectedImage
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettingsContentModel())
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @EnvironmentObject var userSettingsContentModel: UserSettingsContentModel

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                // Resize image to a maximum size of 125x125
                let maxDimension: CGFloat = 125.0
                var newSize = CGSize(width: selectedImage.size.width, height: selectedImage.size.height)
                if selectedImage.size.width > maxDimension || selectedImage.size.height > maxDimension {
                    let aspectRatio = selectedImage.size.width / selectedImage.size.height
                    if selectedImage.size.width > selectedImage.size.height {
                        newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
                    } else {
                        newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
                    }
                }
                let resizedImage = selectedImage.resized(to: newSize)

                // Compress image
                if let compressedImageData = resizedImage.compressTo(0.5) {
                    parent.image = UIImage(data: compressedImageData)
                } else {
                    parent.image = selectedImage
                }
                print("new picture chosen")
                Task {
                    if parent.userSettingsContentModel.userHasProfilePicture {
                        print("updating picture")
                        await parent.userSettingsContentModel.updateProfilePicture(profilePicture: parent.image!)
                    } else {
                        print("uploading new picture")
                        await parent.userSettingsContentModel.uploadProfilePicture(profilePicture: parent.image!)
                    }
                }
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Do nothing
    }
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func compressTo(_ expectedSizeInMb: Double) -> Data? {
        let expectedSizeInBytes = expectedSizeInMb * 1024 * 1024
        var compressionQuality: CGFloat = 1.0
        var image = self
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        while Double(imageData?.count ?? 0) > expectedSizeInBytes {
            compressionQuality -= 0.1
            if compressionQuality <= 0 {
                return nil
            }
            image = UIImage(data: imageData!)!
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        return imageData
    }
}
