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
extension TriviaQuestion {
    init(from apiQuestion: TriviaAPIQuestion) {
        self.number = "\(apiQuestion.incorrect_answers.count + 1)"
        self.category = apiQuestion.category
        self.questionText = apiQuestion.question
        let allAnswers = apiQuestion.incorrect_answers + [apiQuestion.correct_answer]
        self.options = allAnswers
        self.correctAnswerIndex = allAnswers.firstIndex(of: apiQuestion.correct_answer) ?? 0
    }
}

class ForecastViewController: UIViewController {

    // Function override for the view controller
    // This is fired when the view has finished loading for the first time
    override func viewDidLoad() {
        // Some functions require you to call the super class implementation
        // Always read the online documentation to know if you need to
        super.viewDidLoad()
            
            let service = TriviaQuestionService()
            service.fetchQuestions { [weak self] questions in
                guard let strongSelf = self else { return }
                
                guard let questions = questions else {
                    // Handle error if needed
                    return
                }
                strongSelf.questions = questions
                strongSelf.displayQuestion()
            }
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

    
    var questions: [TriviaQuestion] = [
        TriviaQuestion(number: "1", category: "Science", questionText: "What planet is known as the red planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], correctAnswerIndex: 1),
        TriviaQuestion(number: "2", category: "Math", questionText: "What is 2 + 2?", options: ["3", "4", "5", "6"], correctAnswerIndex: 1),
        TriviaQuestion(number: "3", category: "Geography", questionText: "What is the capital of France?", options: ["London", "Berlin", "Madrid", "Paris"], correctAnswerIndex: 3)
    ]
    func displayQuestion() {
        let question = questions[currentQuestionIndex]
        num.text = "Question \(currentQuestionIndex + 1) out of 10"
        cat.text = question.category
        
        let randomColor = changeColor()
        cat.textColor = randomColor
        num.textColor = randomColor
        que.textColor = randomColor
        que.text = question.questionText
        
        // Hide all answer buttons first
        op1.isHidden = true
        op2.isHidden = true
        op3.isHidden = true
        op4.isHidden = true
        
        // Dynamically show buttons based on the number of options
        if question.options.count > 0 {
            op1.isHidden = false
            op1.setTitle(question.options[0], for: .normal)
        }
        if question.options.count > 1 {
            op2.isHidden = false
            op2.setTitle(question.options[1], for: .normal)
        }
        if question.options.count > 2 {
            op3.isHidden = false
            op3.setTitle(question.options[2], for: .normal)
        }
        if question.options.count > 3 {
            op4.isHidden = false
            op4.setTitle(question.options[3], for: .normal)
        }
        
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
        
        let service = TriviaQuestionService()
        service.fetchQuestions { [weak self] questions in
            guard let strongSelf = self else { return }
            
            guard let questions = questions else {
                // Handle error if needed
                return
            }
            
            strongSelf.questions = questions
            strongSelf.currentQuestionIndex = 0
            strongSelf.score = 0
            strongSelf.displayQuestion()
            
            // Unhide buttons if they were hidden
            strongSelf.op1.isHidden = false
            strongSelf.op2.isHidden = false
            strongSelf.op3.isHidden = false
            strongSelf.op4.isHidden = false
        }
    }
    
    

}
class TriviaQuestionService {
    let baseURL = "https://opentdb.com/api.php?amount=10"
    
    func fetchQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let questions = response.results.map { TriviaQuestion(from: $0) }
                completion(questions)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

struct TriviaResponse: Decodable {
    let results: [TriviaAPIQuestion]
}

struct TriviaAPIQuestion: Decodable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    // Convert API data to our TriviaQuestion model
    func toTriviaQuestion() -> TriviaQuestion {
        let allAnswers = incorrect_answers + [correct_answer]
        let correctIndex = allAnswers.firstIndex(of: correct_answer) ?? 0
        return TriviaQuestion(number: "\(allAnswers.count)", category: category, questionText: question, options: allAnswers, correctAnswerIndex: correctIndex)
    }
}
