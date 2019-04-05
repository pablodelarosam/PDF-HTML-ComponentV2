//
//  PDF-HTML.swift
//  PDF-HTML-Component
//
//  Created by Hugo Juárez on 05/04/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import UIKit
import PDFKit
import WebKit

class PDFHTML: UIView, PDFViewDelegate {
    let xibName = "PDF-HTML"
    var pdfURL: URL!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var contentPDF: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    let urlWeb = URL(string: "http://www.pdf995.com/samples/pdf.pdf")

    private func setUpPDFViewer() {
        contentPDF.isHidden = false
        let pdfView = PDFView()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        contentPDF.addSubview(pdfView)
        pdfView.autoScales = true
        pdfView.goToFirstPage(self)
        print(pdfView.currentPage)
        pdfView.leadingAnchor.constraint(equalTo: contentPDF.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: contentPDF.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: contentPDF.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: contentPDF.bottomAnchor).isActive = true
        guard let path = Bundle.main.url(forResource: "sample", withExtension: "pdf") else { return }

        if let document = PDFDocument(url: urlWeb!) {

            pdfView.document = document
        }
    }
    
    private func setUpWebView() {
        navBar.isHidden = true
        webView.isHidden = false
        webView.translatesAutoresizingMaskIntoConstraints = false        
        webView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        webView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        webView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        let htmlString = "<p>Identify the arrow-marked structures in the images<img alt=\"\" src=\"https://dams-apps-production.s3.ap-south-1.amazonaws.com/course_file_meta/73857742.PNG\"></p>"
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let link = "link"
        let activityController = UIActivityViewController(activityItems: [link], applicationActivities: [])
        let activevc = UIApplication.shared.keyWindow?.rootViewController
        
        activevc?.present(activityController, animated: true, completion: nil)
        
    }
    
    override func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
    }
    
    private func getExtensionInfo(of extensionFile: String) {
        if extensionFile == "pdf" {
            setUpPDFViewer()
        } else if extensionFile == "html" {
            setUpWebView()
        }
    }
    
    @IBAction func download(_ sender: UIBarButtonItem) {
        
        guard let url = urlWeb else { return }
        _ = UIApplication.shared.keyWindow?.rootViewController
        let urlSession = URLSession(configuration: .default, delegate: self , delegateQueue: OperationQueue())
        
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        // setUpPDFViewer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        //setUpPDFViewer()
    }
    
    func xibSetup() {
        Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
        contentView.fixInView(self)
      ///  setUpPDFViewer()
        webView.isHidden = true
        contentPDF.isHidden = true
        getExtensionInfo(of: "html")
    }
    
    
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
extension UIView:  URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        var pdfURL: URL!
        // create destination URL with the original pdf name
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            pdfURL = destinationURL
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
    }

