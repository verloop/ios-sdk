//
//  VerloopTestTableViewController.swift
//  VerifyVerloop
//
//  Created by Sreedeep on 22/03/22.
//

import UIKit


class InputCell:UITableViewCell {
    
    @IBOutlet weak var mSecondField: UITextField!
    @IBOutlet weak var mField: UITextField!
    @IBOutlet weak var mTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mField.tag = 0
        mSecondField.tag = 1

    }
    
    func configureCell(model:RowModel) {
        mTitle.text = model.titleToBeShown
        mField.text = model.valueToBeshown
        mSecondField.isHidden = true
        mField.placeholder = model.keyPlaceHolder
        mField.text = model.valueToBeshown
        if model.isMultiInputs {
            mField.text = model.keysToBeShown
            mSecondField.text = model.valueToBeshown
            mSecondField.isHidden = false
            mSecondField.placeholder = model.valuePlaceHolder
            mSecondField.text = model.secondValueToBeshown
        }
    }
}

class ActionCell:UITableViewCell {
    
    @IBOutlet weak var mActionBtn: UIButton!
    @IBOutlet weak var mTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mActionBtn.layer.cornerRadius = 5
        mActionBtn.layer.borderColor = UIColor.blue.cgColor
        mActionBtn.layer.borderWidth = 1

    }
    func configurecell(model:RowModel) {
        mTitle.text = model.valueToBeshown
        mActionBtn.setTitle(model.titleToBeShown, for: .normal)
    }
}

class VerloopTestTableViewController: UITableViewController {
    @IBOutlet weak var mclearBtn: UIButton!
    @IBOutlet weak var mLaunchBtn: UIButton!
    @IBOutlet var footerParentView: UIView!
    
    private let viewModel = ViewModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        mclearBtn.layer.cornerRadius = 5
        mclearBtn.layer.borderColor = UIColor.blue.cgColor
        mclearBtn.layer.borderWidth = 1
        
        mLaunchBtn.layer.cornerRadius = 5
        mLaunchBtn.layer.borderColor = UIColor.blue.cgColor
        mLaunchBtn.layer.borderWidth = 1

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.tableView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Verloop"
//        var frame = footerParentView.frame
//        frame.origin.y = self.navigationController?.view.frame.size.height ?? 500 - frame.size.height
//        footerParentView.frame = frame
//        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
//        self.navigationController?.view.addSubview(footerParentView)
    }

    @objc private func dismissKeyboard() {
        self.tableView.endEditing(true)
    }
    
    @IBAction func onLaunchChat(_ sender: Any) {
        dismissKeyboard()
        let config = viewModel.getInputsConfig()
        if config == nil {
            let alrt = UIAlertController(title: "Error", message: "Please fill mandatory fields and try again.", preferredStyle: .alert)
            alrt.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alrt, animated: true, completion: nil)
            return
        }
        print("config \(config!.description)")
        viewModel.launchChatOn(controller: self, config: config!)
    }
    
    @IBAction func onClear(_ sender: Any) {
        
        viewModel.clearChatInputs()
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfrowsToDisplayed(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.getModelAtIndex(indexPath)
        if model.isInputType {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell") as? InputCell {
                cell.configureCell(model: model)
                cell.mField.addTarget(self, action: #selector(onFieldEdit), for: .editingChanged)
                cell.mSecondField.addTarget(self, action: #selector(onFieldEdit), for: .editingChanged)
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as? ActionCell {
            cell.configurecell(model: model)
            cell.mActionBtn.addTarget(self, action: #selector(onActionbtn), for: .touchUpInside)
            return cell
        }
        return UITableViewCell(frame: .zero)
    }
    
    @objc private func onFieldEdit(field:UITextField) {
        if let cell = field.superview?.superview?.superview?.superview as? InputCell,let indexpath = tableView.indexPath(for: cell) {
            viewModel.didChangeModelInput(field.text ?? "", modelIndex: indexpath,isSecondaryField: field.tag == 1)
        }
    }
    
    @objc private func onActionbtn(btn:UIButton) {
        if let cell = btn.superview?.superview?.superview as? ActionCell,let indexpath = tableView.indexPath(for: cell) {
            viewModel.launchChatWithAction(indexPath: indexpath, controller: self)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return footerParentView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(viewModel.getSectionHeight(TestSections.init(rawValue: section)!))
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width-32, height: 44))
        label.text = viewModel.getTitleForSection(section: TestSections.init(rawValue: section)!)
        label.numberOfLines = 0
        label.textColor = .white
        v.backgroundColor = .blue
        label.center.y = v.center.y
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        v.addSubview(label)
        return v
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
