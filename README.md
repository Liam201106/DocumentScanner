# DocumentScanner
 
Add Package .. 로 https://github.com/Liam201106/DocumentScanner.git 을 입력하여 사용할 타겟에 추가한다.

타겟의 Info.plist 에 Privacy - Camera Usage Description 추가.

- 사용방법

  import DocumentScanner

        let scannerVC = DocumentScannerViewController()
        
        scannerVC.onImageSelected = { selectedImage in
            // 선택된 이미지 처리
        }
        scannerVC.cancelAction = {
            // 취소 처리
        }

        self.viewController!.present(scannerVC, animated: true)


- onImageSelected : 스캔 후 선택된 이미지 (가로세로 사이즈 최대 1024 로 리사이징)
- cancelAction : 사용자 취소시 처리

VNDocumentCameraViewControllerDelegate 를 통해 스캔된 이미지들을 가져온 뒤 스크롤뷰에서 선택된 이미지를 리턴 받는다.
