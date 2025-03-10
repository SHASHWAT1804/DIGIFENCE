import UIKit
import FirebaseAuth
import FirebaseFirestore

class GuestProfileViewController: UIViewController {
    
    @IBOutlet weak var guestProfileImageView: UIImageView!
    @IBOutlet weak var guestNameLabel: UILabel!
    @IBOutlet weak var guestEmailLabel: UILabel!
    @IBOutlet weak var guestRoleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGuestProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGuestProfile()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGuestEditProfile" {
            if let guestEditVC = segue.destination as? GuestEditProfileViewController {
                guestEditVC.guestUserData = [
                    "name": guestNameLabel.text ?? "",
                    "email": guestEmailLabel.text ?? "",
                    "role": guestRoleLabel.text ?? "",
                    //"mobile": guestMobileLabel.text ?? "" // if you add this field on profile
                ]
            }
        }
    }

    
    func fetchGuestProfile() {
        guard let user = Auth.auth().currentUser else {
            print("Guest not logged in")
            return
        }
        
        guestEmailLabel.text = user.email ?? "No Email"
        
        let emailPrefix = user.email?.components(separatedBy: "@").first ?? "GuestUser"
        
        let db = Firestore.firestore()
        let userID = user.uid
        
        let source = FirestoreSource.server
        
        db.collection("users").document(userID).getDocument(source: source) { snapshot, error in
            if let error = error {
                print("Error fetching guest user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No guest data found in Firestore")
                DispatchQueue.main.async {
                    self.guestNameLabel.text = emailPrefix.capitalized
                    self.guestRoleLabel.text = "Guest"
                }
                return
            }
            
            let name = data["name"] as? String ?? emailPrefix.capitalized
            let role = "Guest"
            
            DispatchQueue.main.async {
                self.guestNameLabel.text = name
                self.guestRoleLabel.text = role
            }
        }
    }
    
  
    
    @IBAction func guestSignOutButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performGuestSignOut()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func performGuestSignOut() {
        do {
            try Auth.auth().signOut()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = sceneDelegate.window {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "RoleViewController") // Replace with your login VC ID
                
                window?.rootViewController = UINavigationController(rootViewController: loginVC)
                window?.makeKeyAndVisible()
            }
        } catch let signOutError as NSError {
            print("Guest Sign out error: %@", signOutError)
            
            let errorAlert = UIAlertController(title: "Error", message: "Failed to sign out. Please try again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
        }
    }
}
