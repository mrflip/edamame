module God
  def self.setup_email config
    God::Contacts::Email.message_settings = {
      :from           => config[:username], }
    God.contact(:email) do |c|
      c.name          = config[:to_name]
      c.email         = config[:to]
      c.group         = config[:group] || 'default'
    end
    if config[:address] then delivery_by_smtp(config)
    else                     delivery_by_gmail(config) end
  end

  #
  # GMail
  #
  # http://millarian.com/programming/ruby-on-rails/monitoring-thin-using-god-with-google-apps-notifications/
  def self.delivery_by_gmail config
    require 'tlsmail'
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    God::Contacts::Email.server_settings = {
      :address        => 'smtp.gmail.com',
      :tls            => 'true',
      :port           => 587,
      :domain         => config[:email_domain],
      :user_name      => config[:username],
      :password       => config[:password],
      :authentication => :plain
    }
  end

  #
  # SMTP email
  #
  def self.delivery_by_smtp config
    God::Contacts::Email.server_settings = {
      :address        => config[:address],
      :port           => 25,
      :domain         => config[:email_domain],
      :user_name      => config[:username],
      :password       => config[:password],
      :authentication => :plain,
    }
  end
end
