require "xmlsimple"
require "yaml/store"

require './app/models/exam_model'

class ExamController < ApplicationController
  
    get '/' do
      check_user
      user_data = get_user_data
      
      @title = "Exam"
      @is_again = 0
      
      lang = get_locale
      exam = Exam.new
      @questions = exam.getQuestions(lang)
      @total_question = @questions.length
      @total_answer = 0
      cookies['total_question'] = @total_question
    
      erb :"user/exam/index", layout: :user_layout

    end

    post '/answer' do
      check_user
      LOGGER.debug "Answer data: " + params.to_s
      user_answer = params['q']
      is_again =  params['is_again']

      correct = 0
      incorrect = 0
      incorrect_questions = {}

      if (is_again.to_s == "1")
        questions = get_incorrect_from_cookies
        LOGGER.debug "IIIIIIIIII: " + questions.to_s
      else
        lang = get_locale
        if questions.nil?
          exam = Exam.new
          questions = exam.getQuestions(lang)
        end
      end
            
      i = 0
      questions.each do |question|
        user_option = user_answer[question.id.to_s]
        correct_option = question.answer
        if correct_option.to_s != user_option
          incorrect_questions.store(i, question.id)
          i += 1
        end
      end

      # incorrect_questions = questions.map do |question|
      #   user_option = user_answer[question.id.to_s]        
      #   correct_option = question.answer
      #   if correct_option.to_s != user_option
      #     incorrect += 1
      #     question
      #   end
      # end

      # unless incorrect_questions.nil?
        correct = cookies['total_question'].to_i - incorrect_questions.length
        cookies['incorrect_questions'] = incorrect_questions
        cookies['incorrect'] = incorrect_questions.length
        cookies['correct'] = correct
      # end

      LOGGER.debug "Incorrect: " + incorrect.to_s
      LOGGER.debug "Correct: " + correct.to_s
      LOGGER.debug "Question Incorrect: " + incorrect_questions.to_s

      redirect '/exam/result'
    end

    # Do again with incorrect questions
    get '/again' do      
      check_user
      @title = "Exam"
      
      questions = get_incorrect_from_cookies
      LOGGER.debug "DDDD: " + questions.to_s
      
      if questions.nil? || questions.length == 0
        LOGGER.debug "Incorrect list is empty"
        redirect '/'
      end

      @total_answer = cookies['correct']
      @questions = questions
      @total_question = cookies['total_question']
      @is_again = 1
      erb :"user/exam/index", layout: :user_layout
    end

    get '/result' do
      check_user
      @title = "Result"
      
      # Get incorrect question
      incorrect_questions = string_to_hash(cookies['incorrect_questions'])
      incorrect_values = incorrect_questions.values

      # Get all question
      lang = get_locale
      exam = Exam.new
      questionsAll = exam.getQuestions(lang)

      questions = []
      questionsAll.each do |question|
        if incorrect_values.include? question.id
          question.user_correct = 0
        else
          question.user_correct = 1
        end
        questions.push(question)
      end
      
      @questions = questions
      @correct = cookies['correct']
      @incorrect = cookies['incorrect']
      @total_question = cookies['total_question']

      erb :"user/exam/result", layout: :user_layout
    end

    get '/finish' do
      check_user
      @title = "Finish"
      
      erb :"user/exam/finish", layout: :user_layout
    end

    def get_incorrect_from_cookies
      questions = nil
      if (cookies.has_key?('incorrect_questions') && cookies['incorrect_questions'].to_s != '')
        incorrect_questions = string_to_hash(cookies['incorrect_questions'])
        incorrect_values = incorrect_questions.values
        LOGGER.debug "Q incorrect " + cookies['incorrect_questions'].to_s

        questions = []
        lang = get_locale
        exam = Exam.new
        questionsAll = exam.getQuestions(lang)

        questionsAll.each do |question|
          if incorrect_values.include? question.id
            questions.push(question)
          end
        end        
      end
      questions
    end
end