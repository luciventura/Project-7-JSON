//
//  ViewController.swift
//  Project7B
//
//  Created by Luciene Ventura on 13/04/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var searchPetitions = [Petition] ()
    var allPetitions = [Petition] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reference", style: .plain, target: self, action: #selector(reference))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetitions))
        
        
        let urlString : String
        if navigationController?.tabBarItem.tag == 0 {
            urlString =  "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
            
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
    }
    
    
    @objc func filterPetitions() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let submitAction = UIAlertAction(title: "Search", style: .default) { [ weak self, weak ac] action in
            
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        
        let back = UIAlertAction(title: "All Petitions", style: .default)  { [weak self] _ in
            self?.viewDidLoad()
            
        }
        
        
        ac.addAction(submitAction)
        ac.addAction(back)
        present(ac, animated: true)
        
    }
 
    
    func submit(_ found: String) {
    
        allPetitions += petitions
                for item in allPetitions {
                    if item.title.lowercased().contains("\(found.lowercased())") {
                        searchPetitions.append(item)
                    }
                }
        
        petitions.removeAll(keepingCapacity: true)
               petitions += searchPetitions
               tableView.reloadData()
    }
            

    
    @objc func reference() {
        let ac = UIAlertController(title: "This data comes from:", message: "https://api.whitehouse.gov/v1/petitions.json?limit=100", preferredStyle: .alert)
        present(ac, animated: true)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
    }
    

   func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    
    
    
}

//func isOriginal(word: String) -> Bool {
//    guard let firstWord = searchPetitions?.lowercased() else { return false }
//
//    if firstWord == word {
//        return false
//    }
//    return usedWords.contains(word)
//    }
//}
