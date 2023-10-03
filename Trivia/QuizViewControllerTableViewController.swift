// Import the UIKit framework
// You're almost always going to need this when your referencing UI elements in your file
import UIKit

// Class declaration, including the name of the class and its subclass (UIViewController)

struct TriviaQuestion {
    let number: String
    let category: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
}
class ForecastViewController: UIViewController {

    // Function override for the view controller
    // This is fired when the view has finished loading for the first time
    override func viewDidLoad() {
        // Some functions require you to call the super class implementation
        // Always read the online documentation to know if you need to
        super.viewDidLoad()
        displayQuestion()
    }
    
    @IBOutlet weak var cat: UILabel!
    @IBOutlet weak var que: UILabel!
    @IBOutlet weak var num: UILabel!
    
    @IBOutlet weak var op1: UIButton!
    @IBOutlet weak var op2: UIButton!
    @IBOutlet weak var op3: UIButton!
    @IBOutlet weak var op4: UIButton!
    @IBOutlet weak var restart: UIButton!
    
    var currentQuestionIndex = 0
    var score = 0

    
    let questions: [TriviaQuestion] = [
        TriviaQuestion(number: "1", category: "Science", questionText: "What planet is known as the red planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], correctAnswerIndex: 1),
        TriviaQuestion(number: "2", category: "Math", questionText: "What is 2 + 2?", options: ["3", "4", "5", "6"], correctAnswerIndex: 1),
        TriviaQuestion(number: "3", category: "Geography", questionText: "What is the capital of France?", options: ["London", "Berlin", "Madrid", "Paris"], correctAnswerIndex: 3)
    ]
    func displayQuestion() {
        let question = questions[currentQuestionIndex]
        num.text = "Question \(question.number) out of 3"
        cat.text = question.category
        
        let randomColor = changeColor()
        cat.textColor = randomColor
        num.textColor = randomColor
        que.textColor = randomColor
        que.text = question.questionText
        op1.setTitle(question.options[0], for: .normal)
        op2.setTitle(question.options[1], for: .normal)
        op3.setTitle(question.options[2], for: .normal)
        op4.setTitle(question.options[3], for: .normal)
        restart.setTitle("Restart", for: .normal)
    }
    func changeColor() -> UIColor{
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 0.8)
    }
    @IBAction func answerTapped(_ sender: UIButton) {
        let selectedAnswerIndex = sender.tag
            
            // Check if the answer is correct
            if selectedAnswerIndex == questions[currentQuestionIndex].correctAnswerIndex {
                score += 1
            }
            
            // Proceed to the next question or end the game
            currentQuestionIndex += 1
            if currentQuestionIndex < questions.count {
                displayQuestion()
            } else {
                // Game Over or Show Results
                que.text = "Game Over! Your score is \(score)/\(questions.count)"
                op1.isHidden = true
                op2.isHidden = true
                op3.isHidden = true
                op4.isHidden = true
            }
    }
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        
        currentQuestionIndex = 0
        score = 0
        displayQuestion()
        
        // Unhide buttons if they were hidden
        op1.isHidden = false
        op2.isHidden = false
        op3.isHidden = false
        op4.isHidden = false
    }
    
    

}
