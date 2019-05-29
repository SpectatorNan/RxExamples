//
//  WordController.swift
//  RxExamples
//
//  Created by jin on 2019/5/29.
//  Copyright © 2019 晋先森. All rights reserved.
//

import UIKit
import MJRefresh

class WordController: BaseController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        bindViewEvent()
        
    }
 
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.groupTableViewBackground
        $0.registerCell(nib: WordCell.self)
        $0.tableFooterView = UIView()
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
    }
    
    let dataSource = RxTableViewSectionedReloadDataSource<WordSection>(configureCell: { (section, tableView, indexPath, word) -> UITableViewCell in
        let cell = tableView.dequeueReusable(class: WordCell.self)
        cell.word = word
        return cell
    })
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame = self.view.bounds
    }

    func bindViewEvent() {
        
        let viewModel = WordViewModel()
        let input = WordViewModel.Input(searchText: "中国")
        let output = viewModel.transform(input: input)
        
        output.sections.asDriver().drive(tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            output.isRequestNext.onNext(true)
        })
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            output.isRequestNext.onNext(false)
        })
        
        Observable.zip(tableView.rx.itemSelected,tableView.rx.modelSelected(Word.self)).subscribe(onNext: { [weak self] (index,word) in
            self?.tableView.deselectRow(at: index, animated: false)

            SVProgressHUD.showInfo(withStatus: word.ci)
        }).disposed(by: rx.disposeBag)
        
        output.isRequestNext.onNext(true) //
        
        SVProgressHUD.show()
        output.refreshStatus.asObservable().subscribe(onNext: { status in
            
            SVProgressHUD.dismiss()
            switch status {
            case .none:
                break
            case .begingHeaderRefresh:
                self.tableView.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                self.tableView.mj_header.endRefreshing()
            case .begingFooterRefresh:
                self.tableView.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                self.tableView.mj_footer.endRefreshing()
            case .noMoreData:
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }).disposed(by: rx.disposeBag)
        
    }
}
