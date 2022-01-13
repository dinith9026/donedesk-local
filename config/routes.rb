Rails.application.routes.draw do

  root to: 'dashboard#show', as: :signed_in_root
  root to: 'sessions#new'

  delete '/supplements/:s3_key', to: 'supplements#destroy', constraints: { s3_key: /.*/ }

  # Protected
  get '/dashboard' => 'dashboard#show', as: :dashboard
  get '/chat' => 'chat#show', as: :chat
  post '/jobs' => 'jobs#create', as: :jobs

  delete '/sign_out' => 'sessions#destroy', as: 'sign_out'

  put '/settings', to: 'settings#update'

  get '/profile', to: 'current_user#show', as: 'profile'
  get '/profile/edit', to: 'current_user#edit', as: 'edit_profile'
  put '/profile', to: 'current_user#update'
  get '/chat_terms', to: 'current_user#chat_terms', as: 'chat_terms'
  put '/chat_terms', to: 'current_user#accept_chat_terms', as: 'accept_chat_terms'

  put '/current_account', to: 'current_account#update', as: 'current_account'

  # Services
  get '/insurance', to: 'static_pages#insurance', as: :insurance_page
  post '/insurance', to: 'inquiries#insurance', as: :insurance_quote_requests

  get '/payroll', to: 'static_pages#payroll', as: :payroll_page
  post '/payroll', to: 'inquiries#payroll', as: :payroll_requests

  get '/background_check', to: 'static_pages#background_check', as: :background_check_page
  post '/background_check', to: 'inquiries#background_check', as: :background_check_requests

  # Coaching
  get '/compliance_coaching', to: 'static_pages#compliance_coaching', as: :compliance_coaching_page
  get '/hr_coaching', to: 'static_pages#hr_coaching', as: :hr_coaching_page
  get '/health_insurance_coaching', to: 'static_pages#health_insurance_coaching', as: :health_insurance_coaching_page

  get '/terms', to: 'static_pages#terms', as: :terms_page
  get '/privacy_policy', to: 'static_pages#privacy_policy', as: :privacy_policy_page
  get '/logout_or_continue', to: 'static_pages#logout_or_continue', as: :logout_or_continue_page

  resources :accounts, except: :destroy, shallow: true do
    resources :plans, only: [:new, :create]
    resources :offices, only: [:new, :create], controller: 'account_offices'
    post :reinvite, on: :member
    put :deactivate, on: :member
    put :reactivate, on: :member
  end
  resources :assigned_tracks, only: [:destroy]
  resources :assignments, only: [:index, :show, :destroy], shallow: true do
    get :download, on: :member
    put :mark_completed, on: :member
    resources :certificates, only: [:show]
    resources :exams, only: [:new, :create, :show]
  end
  resources :choices, only: [:destroy]
  resources :courses, except: :destroy, shallow: true do
    resources :questions, only: [:new, :create, :edit, :update, :destroy]
    put :deactivate, on: :member
    put :reactivate, on: :member
    get :preview, on: :member
    post :assignments, on: :member, to: 'courses#create_assignments'
    get :supplements, on: :member, to: 'supplements#index', constraints: { format: :zip }
  end
  resources :documents, only: [:index, :destroy], shallow: true do
  end
  resources :document_types do
    resources :employee_records, only: [] do
      resources :documents, only: [:index], controller: :employee_documents
    end
    resources :offices, only: [] do
      resources :documents, only: [:index], controller: :office_documents
    end
  end
  resources :document_groups do
    post :assign, on: :member
    get :copy, on: :member
    get :reassign, on: :member
  end
  resources :document_group_presets do
    post :copy, on: :member
  end
  resources :employee_documents, only: [:edit, :update, :destroy], shallow: true do
    get :download, on: :member
  end
  resources :employee_records, except: [:destroy], shallow: true do
    resources :invites, only: [:new, :create]
    resources :documents, only: [:new, :create], controller: 'employee_documents'
    resources :employee_notes, only: [:new, :create]
    resources :pto_entries, except: [:index]
    resources :time_entries
    resources :time_cards, only: [:index]

    post :assignments, on: :member, to: 'employee_records#create_assignments'
    post :assigned_tracks, on: :member, to: 'employee_records#create_assigned_tracks'
    put :suspend, on: :member
    put :unsuspend, on: :member
    put :terminate, on: :member
    put :rehire, on: :member
  end
  resources :library_documents do
    get :download, on: :member
  end
  resources :office_documents, only: [:edit, :update, :destroy], shallow: true do
    get :download, on: :member
  end
  resources :offices do
    resources :users, only: [:create, :destroy], controller: 'office_users'
    resources :documents, only: [:new, :create], controller: 'office_documents'
  end
  resources :plan_upgrade_requests, only: :create
  resources :pto_entries, only: [:index]
  resources :registrations, only: [:new, :create]
  resources :referrals, only: [:create]
  resources :time_cards, only: [:index]
  resources :time_sheets, only: [:index]
  resources :track_presets do
    post :copy, on: :member
    put :reorder_courses, on: :member
  end
  resources :tracks do
    resources :courses, only: [:create, :update, :destroy], controller: 'track_courses'
    resources :assigned_tracks, only: [:create]
    put :deactivate, on: :member
    put :reactivate, on: :member
  end
  resource :two_factor_settings, only: [:new, :create]
  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    resources :employee_records, only: [:new, :create]
    resources :offices, only: [:create], controller: 'user_offices'
    post :reinvite, on: :member
    put :make_account_manager, on: :member
    put :make_employee, on: :member
  end

  # contact routs
  resource :contacts
  get '/contacts/:id/view' => 'contacts#view'
  get '/contacts/:id/edit' => 'contacts#edit'
  get '/contact_note/:id/note' => 'contact_notes#new'
  post '/contact_note/create' => 'contact_notes#create'


  # Public
  get '/sign_in' => 'sessions#new', as: 'sign_in'

  resources :passwords, controller: 'passwords', only: [:create, :new]
  resource :session, controller: 'sessions', only: [:create]
  resources :users, controller: 'users', only: [:create] do
    resource :password,
      controller: 'passwords',
      only: [:create, :edit, :update]
  end

  resources :passwords, controller: 'passwords', only: [:create, :new]
  resource :session, controller: 'sessions', only: [:create]

  get '/status' => 'status#index'
end
