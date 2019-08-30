//
//  ViewController.swift
//  Swift Magento
//
//  Created by Dmytro on 8/28/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import CoreData
import UIKit

class HomeViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var sliderScrollView: UIScrollView!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var restTask: URLSessionDataTask!

    var storeConfig: StoreConfig?
    var config: MageHomeConfigContent? {
        didSet {
            DispatchQueue.main.async {
                self.setupSlides()
            }
        }
    }

    // MARK: - initial setup -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sliderScrollView.delegate = self

        getConfig()
    }

    func setupSlides() {
        let slides = createSlides()
        setupSlideScrollView(with: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }

    // MARK: - slides setup -

    func createSlides() -> [SlideView] {
        let slides = config?.slider.map { (slideConf) -> SlideView in
            let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
            slide.label.text = slideConf.title
            let urlString = (storeConfig?.base_media_url ?? "") + slideConf.image
            slide.imageView.loadImageUsingCache(withUrl: urlString)
            return slide
        }

        return slides ?? []
    }

    func setupSlideScrollView(with slides: [SlideView]) {
        sliderScrollView.contentSize = CGSize(width: sliderScrollView.frame.width * CGFloat(slides.count), height: sliderScrollView.frame.height)
        sliderScrollView.isPagingEnabled = true

        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: sliderScrollView.frame.width * CGFloat(i), y: 0, width: sliderScrollView.frame.width, height: sliderScrollView.frame.height)
            sliderScrollView.addSubview(slides[i])
        }
    }

    // MARK: - ScrollView delegate  -

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    // MARK: - Rest Actions  -

    func getConfig() {
        let request: NSFetchRequest<StoreConfig> = StoreConfig.fetchRequest()
        storeConfig = try? context.fetch(request).first
        
        if storeConfig == nil {
            updateConfig()
        } else {
            getHomeConfig()
        }
    }

    func updateConfig() {
        restTask?.cancel()

        restTask = MagentoClient.shared.getConfig {
            if let configs = $0.value {
                let fetchedConfig = self.storeConfig ?? StoreConfig(context: self.context)
                fetchedConfig.base_media_url = configs.first?.base_media_url
                self.storeConfig = fetchedConfig
                
                self.saveData()
                
                self.getHomeConfig()
            }
        }
    }

    func getHomeConfig() {
        restTask?.cancel()

        restTask = MagentoClient.shared.getHomeConfig(completion: { result, _ in
            if result != nil {
                self.config = result
            }
        })
    }
    
    // MARK: - Save Data -
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    // MARK: - END -
}
