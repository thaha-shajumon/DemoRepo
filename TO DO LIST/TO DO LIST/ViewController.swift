//
//  ViewController.swift
//  TO DO LIST
//
//  Created by actionfi on 21/03/1946 Saka.
//

import UIKit
struct UserInputs:Codable {
    var task : String
    var subTask : String
    var imageData : Data?
}
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    private let table : UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self,forCellReuseIdentifier: "cell")
        return table
    }()
    var items = [UserInputs]()
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()
        title = "TO DO LIST"
        view.addSubview(table)
        table.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))

    }
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New item", message: "Enter new tasks", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter your task ..."
        }
        alert.addTextField { sub in
            sub.placeholder = "Enter subtask"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self]
            _ in
            guard let self = self else{ return }
            
            if let field = alert.textFields?.first, let sub = alert.textFields?.last{
                if let text = field.text,!text.isEmpty,let subText = sub.text,!subText.isEmpty{
                    
                    //adding the item
                    let item = UserInputs(task: text, subTask: subText,imageData: self.image?.jpegData(compressionQuality: 1.0))
                    DispatchQueue.main.async {
                    self.items.append(item)
                    self.saveItems()
                    self.table.reloadData()
                    }
                    
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Add image", style: .default, handler: { [weak self]
            _ in
            guard let self = self else{return}
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.task)"
        cell.detailTextLabel?.text = "\(item.subTask)"
        if let imageData = item.imageData{
            cell.imageView?.image = UIImage(data: imageData)
        }
        else{
            cell.imageView?.image = nil
        }
        return cell
    }
    //save items to user defaults
    private func saveItems(){
        if let encoded = try? JSONEncoder().encode(items){
            UserDefaults.standard.set(encoded,forKey: "items")
        }
    }
    //load items from user defaults
    private func loadItems(){
        if let savedItems = UserDefaults.standard.data(forKey: "items"){
            if let decodedItems = try?JSONDecoder().decode([UserInputs].self, from: savedItems){
                items = decodedItems
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    


}

