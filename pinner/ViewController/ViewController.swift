//
//  ViewController.swift
//  pinner
//
//  Created by Adis on 15/09/2017.
//  Copyright © 2017 Infinum. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController, UIActionSheetDelegate {
    
    var sessionManager = SessionManager()
    let customSessionDelegate = CustomSessionDelegate()
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var activityIdicator: UIActivityIndicatorView!
    
    var domainList:[(name: String, url: String)] = [(name: "CB Production District list" , url: "https://api.cashbaba.com.bd//api/v1/common/districtlist"), (name: "CB Production Swaggger" , url: "https://api.cashbaba.com.bd/swagger/index.html"), (name: "CB SAN District list" , url: "https://dev.cash-baba.com:11443/api/v1/Common/DistrictList"), (name: "Google" , url: "https://www.google.com") ]
    
    var domain = "https://google.com"
    let shortDomain = "api.cashbaba.com.bd"
    let certificateURL = Bundle.main.url(forResource: "api-cashbaba-com-bd", withExtension: "cer")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIdicator.isHidden = true
    }
    
    
    // MARK: - Actions -
    @IBAction func changeCertificate(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nextVc = storyboard.instantiateViewController(withIdentifier: "CertificatesViewController") as? CertificatesViewController
        nextVc?.selectedCertificate = { [weak self] certificate in
            self?.displayAlart(title: "Certificate", messageg: certificate.name ?? "")
        }
        self.navigationController?.pushViewController(nextVc!, animated: true)
    }
    
    @IBAction func changeDomain(_ sender: UIBarButtonItem) {
        self.actionSheet()
    }
    
    func actionSheet() {
        let domainMenu = UIAlertController(title: "Domain", message: "Current domain: \(self.domain)", preferredStyle: .actionSheet)
        
        for item in domainList {
            let sName = UIAlertAction(title: item.name, style: .default, handler: { [weak self]
                (alert: UIAlertAction!) -> Void in
                self?.domain = item.url
                self?.displayAlart(title: "Domain", messageg: item.url)
            })
            domainMenu.addAction(sName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancled")
        })
        domainMenu.addAction(cancelAction)
        self.present(domainMenu, animated: true, completion: nil)
    }
    
    func displayAlart(title: String, messageg:String){
        let refreshAlert = UIAlertController(title: title, message: messageg, preferredStyle: UIAlertController.Style.alert)
//        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
//            print("Handle Cancel Logic here")
//        }))
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    fileprivate func showResult(success: Bool) {
        self.activityIdicator.stopAnimating()
        self.activityIdicator.isHidden = true
        
        if success {
            resultLabel.textColor = UIColor(red:0.00, green:0.75, blue:0.00, alpha:1.0)
            resultLabel.text = "🚀 Success"
        } else {
            resultLabel.textColor = .black
            resultLabel.text = "🚫 Request failed"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.resultLabel.text = ""
        }
    }
    
    @IBAction func testWithNoPin() {
        self.activityIdicator.isHidden = false
        self.activityIdicator.startAnimating()
        
        Alamofire.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithAlamofireDefaultPin() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            ),
            "insecure.expired-apis.com": .disableEvaluation
        ]
        
        sessionManager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        self.activityIdicator.isHidden = false
        self.activityIdicator.startAnimating()
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithCustomPolicyManager() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            ),
            "insecure.expired-apis.com": .disableEvaluation
        ]
        
        sessionManager = SessionManager(
            serverTrustPolicyManager: CustomServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        self.activityIdicator.isHidden = false
        self.activityIdicator.startAnimating()
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithNSURLSessionPin() {
        self.activityIdicator.isHidden = false
        self.activityIdicator.startAnimating()
        
        let url = URL(string: domain)! // Pardon my assumption
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                self.showResult(success: response != nil)
            }
        })
        task.resume()
    }
    
    @IBAction func testWithCustomSessionDelegate() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]

        sessionManager = SessionManager(
            delegate: customSessionDelegate, // Feeding our own session delegate
            serverTrustPolicyManager: CustomServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        self.activityIdicator.isHidden = false
        self.activityIdicator.startAnimating()
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }

}

extension ViewController: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Compare the server certificate with our own stored
//        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
//            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
//
//            if pinnedCertificates().contains(serverCertificateData) {
//                completionHandler(.useCredential, URLCredential(trust: trust))
//                return
//            }
//        }
        
        // Or, compare the public keys
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0), let serverCertificateKey = publicKey(for: serverCertificate) {
            if pinnedKeys().contains(serverCertificateKey) {
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    fileprivate func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch (_) {
                // Handle error
            }
        }
        
        return certificates
    }
    
    fileprivate func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch (_) {
                // Handle error
            }
        }
        
        return publicKeys
    }
    
    // Implementation from Alamofire
    fileprivate func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
    
}

