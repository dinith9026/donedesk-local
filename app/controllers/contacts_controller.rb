class ContactsController < ApplicationController
  def index
  end

  def show
		contact = Contact.new
    authorize contact

		@contacts =
      Contact.all
      .page(params[:page])
      .per(20)
  end

  def new
		authorize Contact.new
		@form = Contact.new
  end

	def view
		contact = Contact.new
		authorize contact
		@contact_details = Contact.find(params[:id])
	end

	def create	
		contact = Contact.new
    authorize contact
		@is_edit = false
		
		if params[:contact][:type] == 'new'
			@contact = Contact.new(contact_params_for_create)
			if current_user.office
				@contact.office_id = current_user.office.id
			end
			
			if @contact.save
				@note = ContactNote.new
				@note.note = params[:contact][:note]
				@note.contact_id = @contact.id
				@note.save
	
				set_flash_success_and_redirect_to(new_contacts_path(@group))
			else
				set_flash_error_and_redirect_to(new_contacts_path, 'Invalid data, Please try again...!!!')
			end
		else
			update
		end
	end

	def update
		contact = Contact.find_by(id: params[:contact][:id])
		contact.first_name = params[:contact][:first_name]
		contact.last_name = params[:contact][:last_name]
		contact.contact_address = params[:contact][:contact_address]
		contact.contact_email = params[:contact][:contact_email]
		contact.contact_number_1 = params[:contact][:contact_number_1]
		contact.contact_number_2 = params[:contact][:contact_number_2]
		contact.document = params[:contact][:document]

		if contact.save
			set_flash_success_and_redirect_to(new_contacts_path(@group))
		else
			set_flash_error_and_redirect_to(new_contacts_path, 'Invalid data, Please try again...!!!')
		end
	end

	def edit
		@form = Contact.new
    authorize @form
		@is_edit = true

		contact_details = Contact.find(params[:id])
		@form.first_name = contact_details.first_name
		@form.last_name = contact_details.last_name
		@form.contact_email = contact_details.contact_email
		@form.contact_address = contact_details.contact_address
		@form.contact_number_1 = contact_details.contact_number_1
		@form.contact_number_2 = contact_details.contact_number_2
	end

  private

  def contact_params_for_create
		params
			.require(:contact)
			.permit(:first_name, :last_name,
							 :contact_email, :contact_address,
							 :contact_number_1, :contact_number_2,
							 :office_id, document: [])
  end
end