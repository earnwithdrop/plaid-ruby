module OldPlaid
  class Institution
    attr_accessor :id, :name, :type, :has_mfa, :mfa, :credentials, :products, :url, :fields, :colors, :name_break, :logo

    def initialize(fields = {})
      @id = fields['id']
      @name = fields['name']
      @type = fields['type']
      @has_mfa = fields['has_mfa']
      @mfa = fields['mfa']
      @credentials = fields['credentials']
      @products = fields['products']
      @url = fields['url']
      @fields = fields['fields']
      @colors = fields['colors']
      @name_break = fields['nameBreak']
      @logo = fields['logo']
    end

    # API: semi-private
    # This method takes an array returned from the API and instantiates all of the institutions
    def self.all(res)
      res.map { |inst| new(inst) }
    end
  end
end

