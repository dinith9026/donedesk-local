class Contact < ApplicationRecord
    belongs_to :office
    has_many :contact_documents
    has_many :contact_notes

    has_many_attached :document
end