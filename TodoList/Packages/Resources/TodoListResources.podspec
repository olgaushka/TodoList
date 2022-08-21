Pod::Spec.new do |spec|
  spec.name         = "TodoListResources"
  spec.version      = "0.0.1"
  spec.summary      = "Resources for ToDo list application"
  spec.license      = "MIT"
  spec.homepage     = "https://github.com/olgaushka/TodoList"
  spec.author       = { "Olga Zorina" => "olgzorina@yandex.ru" }
  spec.source       = { :git => "" }

  spec.platform     = :ios, "13.0"

  spec.source_files = "Sources/**/*.swift"
  spec.resource_bundles = {
    'TodoListResourcesBundle' => [
      'Resources/Assets.xcassets'
    ]
  }
end
