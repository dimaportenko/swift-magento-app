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
    @IBOutlet var containerScrollView: UIScrollView!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var restTask: URLSessionDataTask!

    var storeConfig: StoreConfig?
    var config: HomeConfigContent? {
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

        configureRefreshControl()
        
        getConfig()
    }

    func setupSlides() {
        let slides = createSlides()
        setupSlideScrollView(with: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }

    // MARK: - refresh control -

    func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        containerScrollView.refreshControl = UIRefreshControl()
        containerScrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        // Update your content…
        updateHomeConfig()
    }
    
    func stopRefreshControl() {
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.containerScrollView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - slides setup -

    func createSlides() -> [SlideView] {
        let slides = config?.slider?.array.map { (slideItem) -> SlideView in
            let slideConf = slideItem as! HomeConfigSlide
            let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
            slide.label.text = slideConf.title
            let urlString = (storeConfig?.base_media_url ?? "") + (slideConf.image ?? "")
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
        storeConfig = try? context.fetch(StoreConfig.fetchRequest()).first

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
        config = try? context.fetch(HomeConfigContent.fetchRequest()).first

        if config == nil {
            updateHomeConfig()
        }
    }

    func updateHomeConfig() {
        restTask?.cancel()

        restTask = MagentoClient.shared.getHomeConfig(completion: { result, _ in
            if result != nil {
                if self.config != nil {
                    self.context.delete(self.config!)
                }
                let config = HomeConfigContent(context: self.context)
                if let slides = result?.slider.map({ sl -> HomeConfigSlide in
                    let slide = HomeConfigSlide(context: self.context)
                    slide.title = sl.title
                    slide.image = sl.image
                    slide.homeConfig = config
                    return slide
                }) {
                    config.slider = NSOrderedSet(array: slides)
                }
                
                if let featuredCategoriesConfig = result?.featuredCategories {
                    var featuredCategories = [FeaturedCategory]()
                    for (id, dataDict) in featuredCategoriesConfig {
                        let category = FeaturedCategory(context: self.context)
                        category.id = id
                        category.title = dataDict["title"]
                        category.homeConfig = config
                        featuredCategories.append(category)
                    }
                    
                    config.featuredCategories = NSOrderedSet(array: featuredCategories)
                }
                
                self.config = config
                self.saveData()
            }
            
            
            self.stopRefreshControl()
        })
    }

    // MARK: - CRUD Data -

    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func deleteSet(set: NSOrderedSet?) {
        for object in (set?.array ?? []) {
            self.context.delete(object as! NSManagedObject)
        }
    }

    // MARK: - END -
}
