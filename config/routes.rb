Rails.application.routes.draw do
  root "index#index"
  get 'create', to: "index#create"
  get 'replace', to: "index#replace"
end
