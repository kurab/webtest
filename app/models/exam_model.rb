
require "yaml/store"

class Exam

    def getQuestions(lang)
        questions = nil
        store = YAML::Store.new "./data/questions_" + lang + ".yml"
        store.transaction(true) do
            store.roots.each do |root_name|
                questions = store[root_name]
            end
        end
        return questions;
    end

end