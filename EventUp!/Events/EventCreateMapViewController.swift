//
//  EventCreateCalendarViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 12/4/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import JTAppleCalendar

class EventCreateCalendarViewController: UIViewController {
    let formatter = DateFormatter()
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var dateType: createDateType!
    var date: TimeInterval!
    var delegate: EventCreateCalendarDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
        let currDate = Date(timeIntervalSince1970: date)
        calendar.selectDates([currDate])
        setup()
    }
    
    func setup() {
        self.calendar.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    @IBAction func onTimeChange(_ sender: Any) {
        let calendar = Calendar.current
        var timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .calendar], from: Date(timeIntervalSince1970: date))
        components.minute = timeComponents.minute
        components.hour = timeComponents.hour
        delegate.setDate(date: components.date!.timeIntervalSince1970, which: dateType)
    }
}

extension EventCreateCalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "EventCreateCalendarCell", for: indexPath) as! EventCreateCalendarCell
        
        cell.dateLabel.text = cellState.text
        configureCell(view: cell, cellState: cellState)
        setup()
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(99999999)
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? EventCreateCalendarCell  else { return }
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelection(view: myCustomCell, cellState: cellState)
    }
    
    func handleCellSelection(view: EventCreateCalendarCell, cellState: CellState) {
        if cellState.isSelected {
            view.backgroundColor = UIColor(red: 53.0/255.0, green: 102.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        } else {
            view.backgroundColor = UIColor.white
        }
        
    }
    
    func handleCellTextColor(view: EventCreateCalendarCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            view.dateLabel.textColor = UIColor.black
        } else {
            view.dateLabel.textColor = UIColor.lightGray
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        
        let calendar = Calendar.current
        var timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .calendar], from: date)
        components.minute = timeComponents.minute
        components.hour = timeComponents.hour
        self.date = date.timeIntervalSince1970
        delegate.setDate(date: components.date!.timeIntervalSince1970, which: dateType)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    @IBAction func next(_ sender: UIButton) {
        calendar.scrollToSegment(.next)
    }
    
    @IBAction func previous(_ sender: UIButton) {
        calendar.scrollToSegment(.previous)
    }
    
}
