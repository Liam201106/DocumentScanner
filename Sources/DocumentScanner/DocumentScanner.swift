// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import VisionKit

public class DocumentScannerViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    // 클로저를 통해 선택된 이미지 전달
    public var onImageSelected: ((UIImage) -> Void)?
    // 취소된 경우 처리하는 클로저
    public var cancelAction: (() -> Void)?
    
    // 이미지를 표시할 가로 스크롤 뷰
    private var scrollView: UIScrollView!
    private var imageStackView: UIStackView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // "전송할 이미지를 선택해 주세요." 라벨 추가
        let instructionLabel = UILabel()
        instructionLabel.text = "전송할 이미지를 선택해 주세요."
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .darkGray
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 스크롤 뷰와 StackView 설정
        setupScrollView()
        
        // 재촬영 버튼
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("재촬영", for: .normal)
        scanButton.addTarget(self, action: #selector(startDocumentScanning), for: .touchUpInside)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        
        // 취소 버튼 추가
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelScanning), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        // 버튼들의 Auto Layout 설정
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            scanButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            cancelButton.bottomAnchor.constraint(equalTo: scanButton.bottomAnchor)
        ])
        
        DispatchQueue.main.async {
            self.startDocumentScanning()
        }
    }
    
    private func setupScrollView() {
        // 스크롤 뷰 생성 및 설정
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true    // 수평 스크롤만 활성화
        scrollView.showsVerticalScrollIndicator = false  // 수직 스크롤바 비활성화
        scrollView.showsHorizontalScrollIndicator = true // 수평 스크롤바는 표시
        scrollView.alwaysBounceHorizontal = true // 수평으로만 바운스
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        
        // StackView 생성 및 설정
        imageStackView = UIStackView()
        imageStackView.axis = .horizontal
        imageStackView.spacing = 10
        imageStackView.alignment = .center
        imageStackView.distribution = .fill
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(imageStackView)
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    @objc private func cancelScanning() {
        // 취소 시 처리할 코드
        cancelAction?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func startDocumentScanning() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: false, completion: nil)
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        
        // 기존 StackView의 이미지 제거
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for pageIndex in 0..<scan.pageCount {
            // 스캔된 페이지에서 UIImage 가져오기
            let scannedImage = scan.imageOfPage(at: pageIndex)
            
            // 이미지가 찍혔을 때 가로 스크롤뷰에 이미지 추가
            addImageToScrollView(scannedImage, totalPageCount: scan.pageCount)
        }
        
    }

    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
        // 오류 처리
        print("Error scanning document: \(error.localizedDescription)")
    }

    private func addImageToScrollView(_ image: UIImage, totalPageCount: Int) {
        // 이미지 크기 조정
        guard let resizedImage = resizeImage(image) else { return }
        
        let imageView = UIImageView(image: resizedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 테두리 적용
        imageView.layer.borderColor = UIColor.lightGray.cgColor // 테두리 색상
        imageView.layer.borderWidth = 2.0                       // 테두리 두께
        imageView.layer.cornerRadius = 8.0                      // 둥근 모서리
        imageView.clipsToBounds = true                          // 둥근 모서리 활성화
        
        // 이미지 선택시 클로저 호출
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        imageStackView.addArrangedSubview(imageView)
        
        // 이미지 크기 설정
        if totalPageCount == 1 {
            // 이미지가 1개일 경우
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor), // 뷰의 가로 너비 설정
                imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.8) // 높이를 스크롤뷰에 비례
            ])
        } else {
            // 이미지가 2개 이상일 경우
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0/3.0), // 가로 너비 2/3로 설정
                imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.8) // 높이를 스크롤뷰에 비례
            ])
        }
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1024) -> UIImage? {
        let originalSize = image.size
        let aspectRatio = originalSize.width / originalSize.height

        // 최대값이 1024가 되도록 크기 조정
        let newSize: CGSize
        if aspectRatio > 1 { // 가로가 더 길 경우
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else { // 세로가 더 길거나 같을 경우
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        print("Original size: \(originalSize), New size: \(newSize)")
        
        // 새 크기로 이미지 생성
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        print("Resized Image size: \(resizedImage.size)") // 리사이즈된 크기 확인
        
        return resizedImage
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView, let image = imageView.image {
            // 선택된 이미지 클로저로 전달
            onImageSelected?(image)
            dismiss(animated: true, completion: nil)
        }
    }
}
