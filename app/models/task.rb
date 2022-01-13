class Task < ApplicationRecord
    belongs_to :account
    has_many :task_document
end