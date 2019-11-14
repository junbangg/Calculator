//
//  ViewController.swift
//  Calculator
//
//  Created by Jun suk Bang on 06/12/2018.
//  Copyright © 2018 Jun Bang. All rights reserved.
//

import UIKit

//TODO: whenever an operand is pressed after the calculation button, the buttonCheck gets triggered and will tell the user to reset
//thinking that the user has pressed the operand before pressing a number

//First thought for this problem is to create a else if for the case of when the calculation button has been pressed
// fix 0+0=?x0
//placeholder variables
var number : String = "" // this is the number that will appear on the display
var priorityTotal : Double = 0.0 // variable to keep track of the prioritized total, multiplication and division
var total : Double = 0.0 // variable to keep track of total for regular calculation, addition and subtraction
var operand : String = "" // to keep track of what the last operand +,-,x,/ was
//arrays
var priorityNumList = [Double]() // list to hold the numbers that need prioritized calculation ex) 5*5+4 -> [5,5]
var buttonPressedList = [String]() // this is an array for all of the buttons pressed
//etc
var colorCounter : Int = 0// counter to keep track of the color for the smily face button
var prioritySwitch : Bool = false // this keep tracks of whether or not a priority operand was pressed or not (multiplication or division)

var calculatorSwitch : Bool = false


class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var display: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func numberButton(_ sender: UIButton) {
        
        number += String(sender.tag)
        display.text = number
        
    }
    
    @IBAction func decimalButton(_ sender: UIButton) {
        //checks if a button was pressed two times in a row or before a number was pressed
        if buttonCheck() == false{
            display.text = "Press reset retard :|"
        }else{
            number += "."
            display.text = number
        }
        
    }
    // most tutorials for calculators on the internet cannot correctly calculate 2x4-3+5x3
    //this is why I used the "priority logic"
    //the idea is that every time +,-,x,/ is pressed, I check whether or not the "prioritySwitch" is on
    //if it is on(true) that means a portion of the equation requires prioritized calculation  -> (2x4)-3+(5x3)
    // so every time an operand button is pressed(for example "-"), and the "prioritySwitch" is on, I calculate the required (2x4) that occured before the pressing of "-" and I add it to "priorityTotal" before carrying on to the next part of the equation
    // on the other hand for the regular + and - operations.. if the "prioritySwitch" is off, I simply add the number in the placeholder variable "number" to "total"
    // I don't have to worry about + and -. I simply add - to the number when the "-" button is pressed and I add everything to "total"
    // and finally when "=" is pressed, I add "total" and "priorityTotal" and display it on the label
    
    @IBAction func addButton(_ sender: UIButton) {
        if buttonCheck() == false{
            display.text = "Press reset retard :|"
        }else{
            buttonPressedList.append("+")
            //check whether we need to do priority calculation or not
            if prioritySwitch == true{
                priorityNumList.append(Double(number)!)
                priorityCalc()// calculates the priority portion of the equation that occured before this button was pressed
                priorityNumList.removeAll() // removes every number in the priorityNumList since calculation has been finished
            //regular calculation
            }else{
                total += Double(number)!
            }
            numberFinished()// resets "number" to ""
            display.text = "+"
            operand = "+"
            prioritySwitch = false
            print(total)
        }
        
        
    }
    @IBAction func subtractButton(_ sender: UIButton) {
        if buttonCheck() == false{
            display.text = "Press a number first ->Reset"
        }else{
            buttonPressedList.append("-")
            if prioritySwitch == true{
                priorityNumList.append(Double(number)!)
                priorityCalc()
                priorityNumList.removeAll()
                
            }else{
                total += Double(number)!
            }
            numberFinished()
            display.text = "-"
            number += "-"
            prioritySwitch = false
        }
        
    }
    @IBAction func multiplicationButton(_ sender: UIButton) {
        if buttonCheck() == false{
            display.text = "Press reset retard :|"
        }else{
            buttonPressedList.append("X")
            
            priorityNumList.append(Double(number)!)
            numberFinished()
            display.text = "X"
            operand = "X"
            
            if prioritySwitch == true{
                priorityCalc()
                priorityNumList.removeAll()
            }else{
                prioritySwitch = true
            }
        }
        
    }
    @IBAction func divisionButton(_ sender: UIButton) {
        if buttonCheck() == false{
            display.text = "Press reset retard :|"
        }else{
            buttonPressedList.append("/")
            priorityNumList.append(Double(number)!)
            numberFinished()
            display.text = "/"
            operand = "/"
            if prioritySwitch == true{
                priorityCalc()
                priorityNumList.removeAll()
            }else{
                prioritySwitch = true
            }
        }
        
    }
    
    @IBAction func calculate(_ sender: UIButton) {
        if buttonCheck() == false{
            display.text = "Press reset retard :|"
        }else{
            buttonPressedList.append("=")
            //when "=" is pressed, you have to check whether the last operand was a +,- or a x,/
            if prioritySwitch == true{
                priorityNumList.append(Double(number)!)
                priorityCalc()
                prioritySwitch = false
                priorityNumList.removeAll()
            }else {
                total += Double(number)!
                print(total)
                
            }
        }
        //this solved the problem where operations were not possible after the calculation button was pressed
        
        if calculatorSwitch == true && prioritySwitch == true{
            numberFinished()
            number = String(priorityTotal)
            display.text = String(priorityTotal)
            priorityTotal = 0.0
        }else {
            numberFinished()
            display.text = String(total + priorityTotal)
            number = String(total + priorityTotal)
            priorityTotal = 0.0
            total = 0.0
        }
            
        
        calculatorSwitch = true
//        calculatorSwitch = calculatorSwitch ? true : false
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        reset()
    }

    @IBAction func smilyButton(_ sender: UIButton) {
        //just a button that changes the text color everytime you push it , pushing reset will chanage it to the default color
        let colorList = [UIColor.red,UIColor.black,UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.brown, UIColor.gray, UIColor.green, UIColor.magenta,UIColor.orange, UIColor.purple, UIColor.purple, UIColor.yellow]
        
        display.text = ":)"
        display.textColor = colorList[colorCounter]
        colorCounter += 1
    }
    
    func numberFinished(){
        buttonPressedList.append(number)
        number = ""
    }
    
    func priorityCalc() {
        //this is where the priority calculation happens
        switch operand{
        case "X":
            //since everytime an operand button is pressed, the priorityNumList is cleaned out, there can only be 2 items in the array at most
            //if there is only one item in priorityNumList that means you just need to calculate the last "number" directly to priorityTotal
            if priorityNumList.count == 1{
                priorityTotal *= priorityNumList[0]
                print(priorityTotal)
            // this is where there are two items in the priorityNumList
            }else{
                priorityTotal += priorityNumList[0] * priorityNumList[1]
                print(priorityTotal)
            }
        case "/":
            if priorityNumList.count == 1{
                priorityTotal /= priorityNumList[0]
            }else{
                priorityTotal = priorityNumList[0] / priorityNumList[1]
            }
        case "+":
            total += Double(number)!
            print(priorityTotal)
            
        default:
            print("nothing happens")
        }
    }
    
    func reset(){
        priorityNumList.removeAll()
        number = ""
        priorityTotal = 0.0
        total = 0.0
        operand = ""
        prioritySwitch = false
        display.textColor = UIColor.lightGray
        display.text = "0"
        calculatorSwitch = false
    }
    
    func buttonCheck() -> Bool{
        
        if display.text! == "0"{
            return false
        }else{
            return true
        }
    
}

}
