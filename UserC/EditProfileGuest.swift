import UIKit
import FirebaseAuth
import FirebaseFirestore

class GuestEditProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var guestNameTextField: UITextField!
    @IBOutlet weak var guestMobileTextField: UITextField!
    
    @IBOutlet weak var guestEmailLabel: UILabel!   // Non-editable
    @IBOutlet weak var guestRoleLabel: UILabel!    // Non-editable
    
    private var datePicker: UIDatePicker!
    
    // Data passed from GuestProfileViewController
    var guestUserData: [String: String] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGuestUI()
        setupDatePicker() // Optional if using DOB later
    }
    
    // MARK: - Setup UI
    private func setupGuestUI() {
        guestNameTextField.text = guestUserData["name"]
        guestEmailLabel.text = guestUserData["email"] ?? "No Email"
        guestRoleLabel.text = guestUserData["role"] ?? "Guest"
        
        guestMobileTextField.text = guestUserData["mobile"]
        
        guestEmailLabel.textColor = .gray
        guestRoleLabel.textColor = .gray
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        // Add datePicker functionality if needed in future
    }
    
    @objc private func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func guestSaveButtonTapped(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        
        let updatedGuestData: [String: Any] = [
            "name": guestNameTextField.text ?? "",
            "mobile": guestMobileTextField.text ?? ""
        ]
        
        db.collection("users").document(userID).setData(updatedGuestData, merge: true) { error in
            if let error = error {
                print("Failed to update: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to save changes.")
            } else {
                print("Guest profile updated successfully!")
                self.showAlert(title: "Success", message: "Profile updated!") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}
