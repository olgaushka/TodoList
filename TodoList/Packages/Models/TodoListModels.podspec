Pod::Spec.new do |spec|
  spec.name         = "TodoListModels"
  spec.version      = "0.0.1"
  spec.summary      = "ToDo list application models"
  spec.license      = "MIT"
  spec.homepage     = "https://github.com/olgaushka/TodoList"
  spec.author       = { "Olga Zorina" => "olgzorina@yandex.ru" }
  spec.source       = { :git => "" }

  spec.platform     = :ios, "13.0"

  spec.source_files = "Sources/**/*.swift"
end
