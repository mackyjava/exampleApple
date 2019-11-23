
import UIKit

class StoreItemListTableViewController: UITableViewController {
    struct Item : Codable{
          var artistName: String
    }
    struct Items: Codable {
        var results: [Item]
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    // add item controller property
    
    var items = [String]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchMatchingItems() {
        
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            // set up query dictionary
            let query: [String:String] = [
                "media":"\(mediaType)",
                "term":"\(searchTerm)",
                ]
            let baseURL = URL(string: "https://itunes.apple.com/search")!
            guard let url = baseURL.withQueries(query) else { return}
            _ = URLSession.shared.dataTask(with: url) { (data, response, error) in
                       let decoder = JSONDecoder()
                       decoder.keyDecodingStrategy = .convertFromSnakeCase
                       if let data = data {
                        if let movieInfo  = try? decoder.decode(Items.self, from: data) {
                           }else {
                               print("json error" )
                           }
                       }
            }.resume()
        }
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item
        
        // set label to the item's name
        // set detail label to the item's subtitle
        // reset the image view to the gray image
        
        // initialize a network task to fetch the item's artwork
        // if successful, use the main queue capture the cell, to initialize a UIImage, and set the cell's image view's image to the 
        // resume the task
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
    
}

extension URL {
    func withQueries(_ queries: [String:String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map{
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
}
