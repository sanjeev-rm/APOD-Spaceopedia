//
//  PickDateTableViewController.swift
//  APOD
//
//  Created by Sanjeev RM on 10/12/22.
//

import UIKit

class PickDateTableViewController: UITableViewController
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dateLabelIndexPath = IndexPath(row: 1, section: 0)
    let datePickerIndexPath = IndexPath(row: 2, section: 0)
    var isDatePickerHidden = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setting the initial and maximum date picker value.
        datePicker.date = Date()
        datePicker.maximumDate = Date()
        
        updateDateLabel()
    }
    
    /// This function updates the date label
    func updateDateLabel()
    {
        dateLabel.text = datePicker.date.formatted(date: .abbreviated, time: .omitted)
    }
    
    /// This function is fired when the date picker value is changed.
    @IBAction func datePickerValueChanged(_ sender: Any)
    {
        updateDateLabel()
    }
    
    /// This the unwind segue function to come back to this VC.
    @IBAction func unwindToPickDateTableVC(segue: UIStoryboardSegue)
    {
    }
    
    /// This function is fired when the segue from this vc to the ApodViewController occurs.
    @IBSegueAction func goApod(_ coder: NSCoder, sender: Any?) -> ViewController?
    {
        let apodVC = ViewController(coder: coder)
        
        // Getting the date in the String format. In the format yyyy-mm-dd.
        let date = datePicker.date.description.prefix(10)
        
        // Setting the urlQuery property of the apodVC instance.
        apodVC?.urlQuery = ["api_key":"jXaZm8mO1NgcDmjlqJjZWRcLgL2iF66sEAgWMUHd", "date":"\(date)"]
        
        // Returning the instance apodVC. This will be presented.
        return apodVC
    }
    
    // MARK: - Table View Functions
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath
        {
        case datePickerIndexPath where isDatePickerHidden :
            return 0
        default :
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath
        {
        case datePickerIndexPath :
            return 340
        case IndexPath(row: 0, section: 0) : // This case is for the first row that is the heading.
            return 122
        default :
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == dateLabelIndexPath
        {
            isDatePickerHidden.toggle()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
