import UIKit
import UniformTypeIdentifiers
import MessageUI

class AddGuestViewController: UIViewController, UIDocumentPickerDelegate, MFMailComposeViewControllerDelegate {
    
    var extractedEmails: [String] = []
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Send Invitation"
        label.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    let selectFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📂 Select CSV File", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    
    let sendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✉️ Send Emails", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.isEnabled = false
        return button
    }()
    
    let emailListView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 0
        textView.backgroundColor = UIColor.systemGray6
        textView.textColor = .label
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOpacity = 0.05
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        selectFileButton.addTarget(self, action: #selector(selectCSVFile), for: .touchUpInside)
        sendEmailButton.addTarget(self, action: #selector(sendMassEmails), for: .touchUpInside)
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(selectFileButton)
        view.addSubview(sendEmailButton)
        view.addSubview(emailListView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectFileButton.translatesAutoresizingMaskIntoConstraints = false
        sendEmailButton.translatesAutoresizingMaskIntoConstraints = false
        emailListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            selectFileButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            selectFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectFileButton.widthAnchor.constraint(equalToConstant: 220),
            selectFileButton.heightAnchor.constraint(equalToConstant: 50),
            
            sendEmailButton.topAnchor.constraint(equalTo: selectFileButton.bottomAnchor, constant: 20),
            sendEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendEmailButton.widthAnchor.constraint(equalToConstant: 220),
            sendEmailButton.heightAnchor.constraint(equalToConstant: 50),
            
            emailListView.topAnchor.constraint(equalTo: sendEmailButton.bottomAnchor, constant: 20),
            emailListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func selectCSVFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .popover

        if let popoverController = documentPicker.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else { return }

        // Start accessing security-scoped resource (required for sandboxed file access)
        if pickedURL.startAccessingSecurityScopedResource() {
            defer { pickedURL.stopAccessingSecurityScopedResource() } // Ensure resource is released
            
            parseCSV(fileURL: pickedURL)
        } else {
            showAlert(title: "Error", message: "Failed to access file.")
        }
    }
    
    func parseCSV(fileURL: URL) {
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8) // Ensure UTF-8 encoding
            let lines = fileContents.components(separatedBy: .newlines)
            var emails: [String] = []
            
            let possibleEmailKeys = ["Email", "email", "E-mail", "e-mail"]
            let headers = lines.first?.components(separatedBy: ",") ?? []
            guard let emailIndex = headers.firstIndex(where: { possibleEmailKeys.contains($0) }) else {
                showAlert(title: "Error", message: "CSV file must contain an 'Email' column.")
                return
            }

            for line in lines.dropFirst() {
                let columns = line.components(separatedBy: ",")
                if columns.indices.contains(emailIndex) {
                    let email = columns[emailIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !email.isEmpty {
                        emails.append(email)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.extractedEmails = emails
                self.emailListView.text = emails.joined(separator: "\n")
                self.sendEmailButton.isEnabled = !emails.isEmpty
                self.sendEmailButton.backgroundColor = emails.isEmpty ? .systemGray : .systemGreen
            }
        } catch {
            showAlert(title: "Error", message: "Failed to read the CSV file. Please try again.")
            print("Failed to parse CSV: \(error.localizedDescription)")
        }
    }

    // Utility function to show alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @objc func sendMassEmails() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(extractedEmails)
            mailComposeVC.setSubject("DigiFence Event Notification")
            mailComposeVC.setMessageBody("Hello,\n\nThis is an official event email from DigiFence.", isHTML: false)
            
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Mail Not Available", message: "Please configure a mail account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}
