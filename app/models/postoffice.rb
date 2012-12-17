class Postoffice < ActionMailer::Base
  
  def message_(recipients, subject, message, inspect='')
    recipients  recipients
    subject     subject
    body        :message => message, :inspect => inspect
    content_type 'text/html'
  end
  
  def template(template_id, recipients, data=nil)
  	template = nil
  	if template_id.to_i == 0
  		template = EmailTemplate.find_by_name(template_id)
    else
    	template = EmailTemplate.find(template_id)
    end
    raise "Could not find Email Template: #{template_id}" unless template
    template.data = data
    @et = template

    begin
      if data and data[:attachments]
          # Rails interprets JSON arrays as hashes with string indices of numbers
          data[:attachments].each { |i, hash|
          attachments[hash[:filename]] = {
            :content_type  => hash[:content_type],
            :body          => File.read("#{Rails.root}/#{hash[:path]}/#{hash[:filename]}")
          }
        }
      end
    rescue  # Rescue from and ignore problems attaching so the email at least is delivered
      logger.info("Could not attach to email:\n#{$!.message}")
    end
    mail(:to => recipients,
         :from => $installation.noreply_email,
         :subject => template.parsed_subject)
  end
end
