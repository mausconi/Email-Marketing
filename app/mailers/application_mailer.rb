class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def send_email_with_delivery_options(campaign_user, subject, smtp_id)

    settings = campaign_user.user.account.smtp_settings.find(smtp_id)

    # Set unique args at header
    headers 'X-SMTPAPI' => { unique_args: { campaign_user_id: campaign_user.id } }.to_json

    headers 'X-SES-CONFIGURATION-SET' => settings.ses_configuration_set

    mail(
      to: campaign_user.user.email,
      reply_to: settings.reply_to.presence || settings.try(:from_email),
      subject: subject,
      from: settings.try(:from_email),
      delivery_method_options: get_options(settings)
    )
  end

  def reply_email_with_delivery_options(mail_to, subject, smtp_id)

    settings = SmtpSetting.find(smtp_id)

    mail(
      to: mail_to,
      reply_to: settings.reply_to.presence || settings.from_email,
      subject: subject,
      from: settings.from_email,
      delivery_method_options: get_options(settings)
    )
  end

  private

  def get_options(settings)
    {
        user_name: settings.username,
        password:  settings.password,
        address:   settings.address,
        port:      settings.port,
        domain:    settings.domain,
        authentication: 'login',
        enable_starttls_auto: true
    }
  end
end
