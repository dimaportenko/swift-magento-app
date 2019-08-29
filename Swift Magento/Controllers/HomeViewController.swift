//
//  ViewController.swift
//  Swift Magento
//
//  Created by Dmytro on 8/28/19.
//  Copyright © 2019 Dmytro. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var sliderScrollView: UIScrollView!

    let slidesData: [[String: String]] = [
        [
            "title": "New Luma Yoga Collection",
            "image": "http://mma.mage2.interactivated.me/media/wysiwyg/home/home-main.jpg",
        ],
        [
            "title": "Even more ways to mix and match",
            "image": "http://mma.mage2.interactivated.me/media/wysiwyg/home/home-t-shirts.png",
        ],
        [
            "title": "Find conscientious, comfy clothing in our eco-friendly collection",
            "image": "http://mma.mage2.interactivated.me/media/wysiwyg/home/home-eco.jpg",
        ],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sliderScrollView.delegate = self
        let slides = createSlides()
        setupSlideScrollView(with: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
//        sliderScrollView.bringSubviewToFront(pageControl)
    }

    // MARK: - slides setup -

    func createSlides() -> [SlideView] {
        let slides = slidesData.map { (slideDict) -> SlideView in
            let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
            slide.label.text = slideDict["title"] ?? ""
            slide.imageView.loadImageUsingCache(withUrl: slideDict["image"] ?? "")
            return slide
        }

        return slides
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
}