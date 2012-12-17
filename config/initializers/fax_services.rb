class EFaxFaxService
  def self.deduce_sender_fax_number_using_envelope(envelope)
    # Check subject
    #   Primary: "19732011333", "915 941 0868", "unknown", "Sender Name"
    #   Seconday: Caller-ID: XXX-XXX-XXXX, Caller-ID: UNAVAILABLE
    primary_match = envelope.subject.match(/"(.+?)"/)
    if primary_match
      primary = primary_match[1].gsub(/[\D]/, '')
      match = primary.match(/\d{10}$/)
      return match[0] if match
    end
    
    secondary_match = envelope.subject.match(/ID:\s*(.+?)$/)
    if secondary_match
      secondary = secondary_match[1].gsub(/[\D]/, '')
      match = secondary.match(/\d{10}$/)
      return match[0] if match
    end
  end
end

class OneSuiteFaxService
  def self.deduce_sender_fax_number_using_envelope(envelope)
    return envelope.subject.scan(/\d{10}/)[0] || envelope.body.scan(/OS FAX Number\s*:\s*(\d{10})/).flatten[0]
  end
end