import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class HostLoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termsCheckBox: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleSignInImageView: UIImageView!
    @IBOutlet weak var appleSignInImageView: UIImageView!
    @IBOutlet weak var passwordToggleButton: UIButton!

    // MARK: - Variables
    var isTermsAccepted = false
    var isPasswordVisible = false
    fileprivate var nonce: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
        setupTapGestures()
    }

    // MARK: - Tap Gestures for Sign-In Image Views
    private func setupTapGestures() {
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(googleSignInTapped))
        googleSignInImageView.isUserInteractionEnabled = true
        googleSignInImageView.addGestureRecognizer(googleTap)

        let appleTap = UITapGestureRecognizer(target: self, action: #selector(appleSignInTapped))
        appleSignInImageView.isUserInteractionEnabled = true
        appleSignInImageView.addGestureRecognizer(appleTap)
    }

    // MARK: - Email/Password Login
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                    return
                }

                print("Login Successful: \(authResult?.user.email ?? "")")
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }

    // MARK: - Google Sign-In
    @objc func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                    return
                }

                guard let result = signInResult,
                      let idToken = result.user.idToken?.tokenString else {
                    self.showAlert(title: "Google Sign-In Failed", message: "Invalid credentials.")
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                        return
                    }
                    print("Google Sign-In Successful: \(authResult?.user.email ?? "")")
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
    }

    // MARK: - Apple Sign-In
    @objc func appleSignInTapped() {
        nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce!)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Forgot Password
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToForgotPassword", sender: self)
    }

    // MARK: - Create Account
    @IBAction func createAccountTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }

    // MARK: - Terms & Conditions Checkbox
    @IBAction func termsCheckBoxTapped(_ sender: UIButton) {
        isTermsAccepted.toggle()
        let imageName = isTermsAccepted ? "checkmark.square.fill" : "square"
        termsCheckBox.setImage(UIImage(systemName: imageName), for: .normal)
        loginButton.isEnabled = isTermsAccepted
    }

    // MARK: - Toggle Password Visibility
    @IBAction func passwordToggleTapped(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Helper Alert Method
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - Apple Sign-In Delegates
extension HostLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8),
                  let nonce = nonce else {
                print("Apple Sign-In: Unable to fetch identity token or nonce.")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Apple Sign-In Failed", message: error.localizedDescription)
                    return
                }
                print("Apple Sign-In Successful: \(authResult?.user.email ?? "")")
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.showAlert(title: "Apple Sign-In Failed", message: error.localizedDescription)
    }

    // MARK: - Nonce Utilities
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
