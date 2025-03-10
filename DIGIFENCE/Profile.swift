import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserProfile()  // Initial fetch when the view loads
    }

    // ✅ Refresh the profile every time the view appears (e.g., after editing)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()  // Refetch user data when returning from Edit Profile
    }
    
    func fetchUserProfile() {
        // Get the currently logged-in user from Firebase Authentication
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        // Set email directly from FirebaseAuth user
        emailLabel.text = user.email ?? "No Email"

        // Get default name from the email prefix if Firestore has no data
        let emailPrefix = user.email?.components(separatedBy: "@").first ?? "User"

        let db = Firestore.firestore()
        let userID = user.uid

        // ✅ Force fetch the latest data from the server (not cache)
        let source = FirestoreSource.server

        db.collection("users").document(userID).getDocument(source: source) { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No user data found in Firestore")
                DispatchQueue.main.async {
                    self.nameLabel.text = emailPrefix.capitalized
                    self.roleLabel.text = "Host"
                }
                return
            }

            let name = data["name"] as? String ?? emailPrefix.capitalized
            let role = "Host" // ✅ Role is fixed

            // Update UI on the main thread
            DispatchQueue.main.async {
                self.nameLabel.text = name
                self.roleLabel.text = role
            }
        }
    }

    // ✅ Prepare for segue to EditProfileViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditProfile" {
            if let editVC = segue.destination as? EditProfileViewController {
                // Pass current profile data to EditProfileViewController
                editVC.userData = [
                    "name": nameLabel.text ?? "",
                    "email": emailLabel.text ?? "",
                    "role": roleLabel.text ?? ""
                ]
            }
        }
    }

    // ✅ Sign Out Button Action
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        // Show alert to confirm sign out
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSignOut()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        // For iPad: Popover presentation (optional safeguard)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func performSignOut() {
        do {
            try Auth.auth().signOut()
            
            // Navigate back to login screen
            // You can modify this depending on your flow
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = sceneDelegate.window {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "RoleViewController") // ⚠️ Replace with your Login VC identifier
                
                window?.rootViewController = UINavigationController(rootViewController: loginVC)
                window?.makeKeyAndVisible()
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            
            // Optional: Show an alert if sign-out fails
            let errorAlert = UIAlertController(title: "Error", message: "Failed to sign out. Please try again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
        }
    }
}
