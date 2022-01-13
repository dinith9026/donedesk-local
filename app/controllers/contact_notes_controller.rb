class ContactNotesController < ApplicationController
  def new
    @contact_notes = ContactNote.new
    authorize @contact_notes
    contact = Contact.find(params[:id])
    @contact_name = contact.first_name
    @contact_name += " "
    @contact_name += contact.last_name
  end

  def create
    contact_notes = ContactNote.new
    authorize contact_notes

    @contact_note = ContactNote.new(contact_note_params)
    if @contact_note.save
      set_flash_success_and_redirect_to(params[:previous_request])
    else
      set_flash_error_and_redirect_to(new_contacts_path, 'Invalid data, Please try again...!!!')
    end

  end

  def show
  end

  private

  def contact_note_params
		params
			.require(:contact_note)
			.permit(:note, :contact_id)
  end
end