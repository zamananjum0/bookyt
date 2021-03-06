class PeopleParams
  # https://github.com/huerlisi/has_vcards/blob/master/app/models/has_vcards/vcard.rb#L37
  PHONE_TYPE_MAPPING = {
    'office' => 'Tel. geschäft',
    'home' => 'Tel. privat',
    'mobile' => 'Handy',
  }

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def to_h
    direct_debit_attributes.merge(vcard_attributes: vcard_attributes)
  end

  def vcard_attributes
    attributes = {
      full_name: full_name,
      address_attributes: address_attributes,
      contacts_attributes: contacts_attributes
    }
    attributes[:id] = vcard_address_id if update?
    attributes
  end

  def full_name
    params[:name]
  end

  def direct_debit_attributes
    {
      direct_debit_enabled: params[:direct_debit_enabled],
      clearing: params[:bank_clearing_number],
      bank_account: params[:bank_account_number],
    }
  end

  def address_attributes
    attributes = {
      extended_address: params[:extended_address],
      street_address: params[:street],
      post_office_box: params[:post_office_box],
      postal_code: params[:zip],
      locality: params[:city],
    }
    attributes
  end

  def contacts_attributes
    attributes = {}
    params[:phone_numbers].each_with_index do |phone_number, index|
      phone_number_type = PHONE_TYPE_MAPPING[phone_number[:type]]
      phone_number_attributes = {
        phone_number_type: phone_number_type,
        number: phone_number[:number],
      }
      phone_number_attributes[:id] = phone_number_id(phone_number_type) if update?
      attributes[index] = phone_number_attributes
    end
    attributes
  end

  def update?
    !!person_id
  end

  def person_id
    params[:id]
  end

  def person
    @person ||= Person.find(person_id)
  end

  def vcard_address_id
    person.vcard.id
  end

  def phone_number_id(type)
    person.vcard.contacts.find_by_phone_number_type(type).try(:id)
  end
end
