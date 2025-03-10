import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!   // Made UILabel (non-editable)
    @IBOutlet weak var roleLabel: UILabel!    // Made UILabel (non-editable)
    
    // For Date Picker (Optional if you want DOB in future)
    private var datePicker: UIDatePicker!
    
    // Data passed from ProfileViewController
    var userData: [String: String] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()  // Optional if DOB is used
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Populate text fields and labels with passed userData
        nameTextField.text = userData["name"]
        emailLabel.text = userData["email"] ?? "No Email"
        roleLabel.text = userData["role"] ?? "Host"
        
        // Optional fields if you expand later (e.g., mobile, dob)
        mobileTextField.text = userData["mobile"]
        
        // Make email and role labels visually distinct as non-editable
        emailLabel.textColor = .gray
        roleLabel.textColor = .gray
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        // Uncomment if DOB field is added
        /*
        dobTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDatePicker))
        toolbar.setItems([doneBtn], animated: true)
        
        dobTextField.inputAccessoryView = toolbar
        */
    }
    
    @objc private func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        // Uncomment if DOB field is added
        // dobTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Validate if the user is logged in
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Prepare updated data to send to Firestore
        let updatedData: [String: Any] = [
            "name": nameTextField.text ?? "",
            // "dob": dobTextField.text ?? "",  // Uncomment if using DOB
            "mobile": mobileTextField.text ?? ""
            // Email and role are fixed and not updated
        ]
        
        // ✅ Use setData with merge: true to update existing document fields
        db.collection("users").document(userID).setData(updatedData, merge: true) { error in
            if let error = error {
                print("Failed to update: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to save changes.")
            } else {
                print("Profile updated successfully!")
                self.showAlert(title: "Success", message: "Profile updated!") {
                    // ✅ Pop back to ProfileViewController after saving
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
