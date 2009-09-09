module God
  def self.setup_email options
    God::Contacts::Email.message_settings = {
      :from           => options[:username], }
    God.contact(:email) do |c|
      c.name          = options[:to_name]
      c.email         = options[:to]
      c.group         = options[:group] || 'default'
    end
    if options[:address] then delivery_by_smtp(options)
    else                     delivery_by_gmail(options) end
  end

  #
  # GMail
  #
  # http://millarian.com/programming/ruby-on-rails/monitoring-thin-using-god-with-google-apps-notifications/
  def self.delivery_by_gmail options
    require 'tlsmail'
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    God::Contacts::Email.server_settings = {
      :address        => 'smtp.gmail.com',
      :tls            => 'true',
      :port           => 587,
      :domain         => options[:email_domain],
      :user_name      => options[:username],
      :password       => options[:password],
      :authentication => :plain
    }
  end

  #
  # SMTP email
  #
  def self.delivery_by_smtp options
    God::Contacts::Email.server_settings = {
      :address        => options[:address],
      :port           => 25,
      :domain         => options[:email_domain],
      :user_name      => options[:username],
      :password       => options[:password],
      :authentication => :plain,
    }
  end
end
