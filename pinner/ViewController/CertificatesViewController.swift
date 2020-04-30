//
//  CertificatesViewController.swift
//  pinner
//
//  Created by Asif Newaz on 30/4/20.
//  Copyright © 2020 Infinum. All rights reserved.
//

import UIKit

enum CertificateType {
    case cer
    case crt
    case der
    case pem
}

struct Certificate {
    var name: String?
    var type: CertificateType?
}

class CertificatesViewController: UIViewController {

    var selectedCertificate: ((_ certificate: Certificate) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func selectCBCertificate(_ sender: UIButton) {
        var certificate = Certificate()
        certificate.name = "api-cashbaba-com-bd"
        certificate.type = .cer
        
        self.navigationController?.popViewController(animated: true)
        if let selectedCertificate = self.selectedCertificate {
            selectedCertificate(certificate)
        }
        
    }
    
    @IBAction func selectSOCertificate(_ sender: UIButton) {
        var certificate = Certificate()
        certificate.name = "so"
        certificate.type = .cer
        
        self.navigationController?.popViewController(animated: true)
        if let selectedCertificate = self.selectedCertificate {
            selectedCertificate(certificate)
        }
        
    }
    
}
