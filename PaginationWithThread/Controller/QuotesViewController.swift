//
//  ViewController.swift
//  PaginationWithThread
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class QuotesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let footerActivityIndicator = UIActivityIndicatorView(style: .medium)
    private let viewModel = QuotesViewModel()
    private let disposeBag = DisposeBag()
    private let noInternetView = NoInternetView()
    var noDataView: NoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupNoDataView()
        setupReachability()
        viewModel.fetchQuotes()
    }
    
    func setupNoDataView() {
        noDataView = NoDataView()
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataView)
        
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        noDataView.isHidden = true
    }
    
    private func setupUI() {
        setupTableViewFooter()
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noInternetView)
        
        NSLayoutConstraint.activate([
            noInternetView.topAnchor.constraint(equalTo: view.topAnchor),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        noInternetView.isHidden = true
        noInternetView.retryButton.addTarget(self, action: #selector(retryFetchingQuotes), for: .touchUpInside)
        
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { [weak self] (_, indexPath) in
                guard let self = self else { return }
                if indexPath.row == self.viewModel.quotes.value.count - 1 {
                    self.footerActivityIndicator.startAnimating()
                    self.viewModel.fetchQuotes()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableViewFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        footerActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerActivityIndicator)
        
        NSLayoutConstraint.activate([
            footerActivityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            footerActivityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }
    
    private func bindViewModel() {
        viewModel.quotes
            .bind(to: tableView.rx.items(cellIdentifier: "QuoteTableViewCell", cellType: QuoteTableViewCell.self)) { row, quote, cell in
                cell.contentLabel.text = "\"\(quote.content)\""
                cell.authorLabel.text = "- \(quote.author)"
            }
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("Binding Error: \(error)")
                self?.showNoDataView()
            })
            .disposed(by: disposeBag)
        
        viewModel.loading
            .observe(on: MainScheduler.instance)
            .bind(to: footerActivityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    private func setupReachability() {
        let reachability = NetworkReachabilityManager()
        
        reachability?.startListening(onQueue: .main, onUpdatePerforming: { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .reachable(_), .unknown:
                self.noInternetView.isHidden = true
                self.viewModel.fetchQuotes()
            case .notReachable:
                self.noInternetView.isHidden = false
            }
        })
    }
    
    func showNoDataView() {
        noDataView.isHidden = false
        tableView.isHidden = true
    }
    
    @objc private func retryFetchingQuotes() {
        if let reachability = NetworkReachabilityManager(), reachability.isReachable {
            noInternetView.isHidden = true
            viewModel.fetchQuotes()
        } else {
            let alert = UIAlertController(title: "Error", message: "No Internet Connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
